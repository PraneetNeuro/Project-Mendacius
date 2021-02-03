//
//  VirtualMachineModal.swift
//  Project Mendacius
//
//  Created by Praneet S and Meghana Khuntia on 26/11/20.
//

import Foundation
import Virtualization
import Cocoa
import Combine

class Singleton: ObservableObject {
    
    private init() {}
    
    enum modesOfOperation {
        case mendacius
        case qemu
    }
    
    public static var shared = Singleton()
    
    func pushNotification(title: String, message: String) {
        let notification = NSUserNotification()
            notification.title = title
            notification.subtitle = message
            notification.soundName = NSUserNotificationDefaultSoundName
            notification.deliveryDate = Date(timeIntervalSinceNow: 5)
            NSUserNotificationCenter.default.deliver(notification)
    }
    
    @Published var currentMode: modesOfOperation = .mendacius
}

class VirtualMachine {
    static func getDetails(VM_Name: String, param: Int) -> Int {
        let decodedObj = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData((UserDefaults.standard.data(forKey: VM_Name) ?? Data(base64Encoded: ""))!) as? VirtualMachineInstance)
        
        if param == 1 {
            if let obj = decodedObj {
                return Int(obj.memorySizeinGB)
            }
        } else if param == 2 {
            if let obj = decodedObj {
                return obj.cpuCount
            }
        }
        return 0
    }
}

class HostMachine {
    
    static var disks: [URL] = []
    
    static var machineHardwareName: String? {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        guard result == EXIT_SUCCESS else { return nil }
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
    
    static func getMaximumCpuCount() -> Int {
        let executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        let out = Pipe()
        let result = Process()
        result.executableURL = executableURL
        result.arguments = ["hw.ncpu"]
        result.standardOutput = out
        try! result.run()
        let res = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        return Int(res?.split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines) ?? "4") ?? 4
    }
    
    static func whoami() -> String {
        let executableURL = URL(fileURLWithPath: "/usr/bin/whoami")
        let out = Pipe()
        let result = Process()
        result.executableURL = executableURL
        result.arguments = []
        result.standardOutput = out
        try! result.run()
        let res = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        return res
    }
    
    static func launchQemu(bootableImageURL: String) {
        let qemuProcess = Process()
        qemuProcess.executableURL = URL(fileURLWithPath: "/usr/local/bin/qemu-system-x86_64")
        qemuProcess.arguments = ["-cdrom", bootableImageURL, "-drive", "file=\(HostMachine.disks.first!.absoluteString)", "-m", "4096"]
        try? qemuProcess.run()
    }
    
}

class VirtualMachineInstance : NSObject, ObservableObject, VZVirtualMachineDelegate, NSCoding, VZVirtioSocketListenerDelegate {
    
    override init() {
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(kernelURL, forKey: "kernelurl")
        coder.encode(bootableImageURL, forKey: "booturl")
        coder.encode(initialRamdiskURL, forKey: "initurl")
        coder.encode(memorySizeinGB, forKey: "memorysize")
        coder.encode(vm_name, forKey: "vmname")
        coder.encode(HostMachine.disks, forKey: "\(vm_name)_disks_of_vm")
        coder.encode(cpuCount, forKey: "cpucount")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        kernelURL = coder.decodeObject(forKey: "kernelurl") as? URL
        bootableImageURL = coder.decodeObject(forKey: "booturl") as? URL
        initialRamdiskURL = coder.decodeObject(forKey: "initurl") as? URL
        vm_name = coder.decodeObject(forKey: "vmname") as! String
        memorySizeinGB = coder.decodeObject(forKey: "memorysize") as? Double ?? UserDefaults.standard.double(forKey: "\(vm_name)_memsize")
        cpuCount = coder.decodeObject(forKey: "cpucount") as? Int ?? Int(UserDefaults.standard.double(forKey: "\(vm_name)_cpucount"))
        HostMachine.disks = coder.decodeObject(forKey: "\(vm_name)_disks_of_vm") as? [URL] ?? []
    }
    
    var vm_name: String = ""
    @Published var virtualMachine: VZVirtualMachine?
    @Published var memorySizeinGB: Double = 0.5
    @Published var cpuCount: Int = 2
    
    @Published var kernelURL: URL?
    @Published var initialRamdiskURL: URL?
    @Published var bootableImageURL: URL?
    
    @Published var state: VZVirtualMachine.State?
    
    public let readPipe = Pipe()
    public let writePipe = Pipe()
    
    public lazy var consoleWindow: NSWindow = {
        let viewController = ConsoleViewController()
        viewController.configure(with: readPipe, writePipe: writePipe)
        return NSWindow(contentViewController: viewController)
    }()
    
    public lazy var consoleWindowController: NSWindowController = {
        let windowController = NSWindowController(window: consoleWindow)
        return windowController
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    var isReady: Bool {
        kernelURL != nil && initialRamdiskURL != nil && bootableImageURL != nil
    }
    
    var stateDescription: String? {
        guard let state = state else {
            return nil
        }
        
        switch state {
            case .stopped:
                return "Stopped"
            case .running:
                return "Running"
            case .paused:
                return "Paused"
            case .error:
                return "Error"
            case .starting:
                return "Starting"
            case .pausing:
                return "Pausing"
            case .resuming:
                return "Resuming"
            @unknown default:
                return "Unknown \(state.rawValue)"
        }
    }
    
    func start() {
        guard let kernelURL = kernelURL,
              let initialRamdiskURL = initialRamdiskURL,
              let bootableImageURL = bootableImageURL else {
            return
        }
        
        cancellables = []
        state = nil
        
        let bootloader = VZLinuxBootLoader(kernelURL: kernelURL)
        bootloader.initialRamdiskURL = initialRamdiskURL
        bootloader.commandLine = "console=hvc0 root=/dev/vda"
        //bootloader.commandLine = "console=tty0"
        
        let serial = VZVirtioConsoleDeviceSerialPortConfiguration()
        serial.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: writePipe.fileHandleForReading,
            fileHandleForWriting: readPipe.fileHandleForWriting
        )
        
        var blockAttachments: [VZVirtioBlockDeviceConfiguration] = []
        
        for disk in HostMachine.disks {
            let blockAttachment_temp : VZDiskImageStorageDeviceAttachment
            do {
                blockAttachment_temp = try VZDiskImageStorageDeviceAttachment(
                    url: disk,
                    readOnly: false
                )
            } catch {
                NSLog("Failed to load bootableImage: \(error)")
                return
            }
            
            let blockDevicetemp = VZVirtioBlockDeviceConfiguration(attachment: blockAttachment_temp)
            blockAttachments.append(blockDevicetemp)
        }
        
        let entropy = VZVirtioEntropyDeviceConfiguration()
        
        let memoryBalloon = VZVirtioTraditionalMemoryBalloonDeviceConfiguration()
        
        let blockAttachment: VZDiskImageStorageDeviceAttachment
        
        do {
            blockAttachment = try VZDiskImageStorageDeviceAttachment(
                url: bootableImageURL,
                readOnly: false
            )
        } catch {
            NSLog("Failed to load bootableImage: \(error)")
            return
        }

        let blockDevice = VZVirtioBlockDeviceConfiguration(attachment: blockAttachment)
        
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()
        
        let config = VZVirtualMachineConfiguration()
        config.bootLoader = bootloader
        config.cpuCount = cpuCount
        config.memorySize = UInt64(memorySizeinGB * 1024 * 1024 * 1024)
        config.entropyDevices = [entropy]
        config.memoryBalloonDevices = [memoryBalloon]
        config.serialPorts = [serial]
        config.storageDevices = [blockDevice]

        for attachments in blockAttachments {
            config.storageDevices.append(attachments)
        }
    
        config.networkDevices = [networkDevice]

        do {
            try config.validate()
            
            let vm = VZVirtualMachine(configuration: config)
            vm.delegate = self
            self.virtualMachine = vm
            KeyValueObservingPublisher(object: vm, keyPath: \.state, options: [.initial, .new])
                .sink { [weak self] state in
                    self?.state = state
                }
                .store(in: &cancellables)
            
            vm.start { result in
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        NSLog("Failed: \(error)")
                }
            }
        } catch {
            NSLog("Error: \(error)")
            return
        }
    }
    
    func stop() {
        cancellables = []
        state = nil
        if let virtualMachine = virtualMachine {
            do {
                try virtualMachine.requestStop()
            } catch {
                NSLog("Failed to stop: \(error)")
            }
            Singleton.shared.pushNotification(title: "Stopping VM", message: "This might take a moment to deinitialise the VM and deallocate the resources")
            self.virtualMachine = nil
        }
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        NSLog("Stopped")
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        NSLog("Stopped with error: \(error)")
    }
    
    func showConsole() {
        consoleWindow.setContentSize(NSSize(width: 400, height: 300))
        consoleWindow.title = vm_name
        consoleWindowController.showWindow(nil)
    }
}
