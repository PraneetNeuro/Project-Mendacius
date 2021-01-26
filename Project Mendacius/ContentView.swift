//
//  ContentView.swift
//  Project Mendacius
//
//  Created by Praneet S and Meghana Khuntia on 26/11/20.
//

import SwiftUI
import UniformTypeIdentifiers
import Virtualization

struct ContentView: View {
    
    let memRatioConstant = 1024 * 1024 * 1024
    
    @StateObject var viewModel: VirtualMachineInstance = VirtualMachineInstance()
    
    @State var isShowingCreateVMSheet: Bool = false
    @State var diskSizeinGB: Double = 10
    @State var diskName: String = ""
    @State var memorySizeinGB: Double = 0.5
    @State var cpuCount: Double = 2
    @State var VM_name: String = ""
    @State var vms_: [String] = UserDefaults.standard.array(forKey: "vms") as? [String] ?? []
    
    private func showConsole() {
        viewModel.showConsole()
    }
    
    enum DropItemType {
        case kernel
        case ramdisk
        case image
    }
    
    private func processDropItem(of type: DropItemType,
                                 items: [NSItemProvider]) {
        guard let item = items.first else {
            return
        }
        
        item.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
            guard let data = data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            DispatchQueue.main.async {
                switch type {
                case .kernel:
                    viewModel.kernelURL = url
                case .ramdisk:
                    viewModel.initialRamdiskURL = url
                case .image:
                    viewModel.bootableImageURL = url
                }
            }
        }
    }
    
    @ObservedObject var appState = Singleton.shared
    
    var body: some View {
        if appState.currentMode == .mendacius {
            HStack {
                VStack {
                    List(vms_, id: \.self) { i in
                        Text(i)
                            .onTapGesture() {
                                VM_name = i
                            }
                    }.listStyle(SidebarListStyle())
                }.frame(width: 175)
                Spacer()
                VStack {
//                    ZStack(alignment: .center) {
//                        RoundedRectangle(cornerRadius: 16)
//                            .frame(width: 400, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                            .padding(.top)
//                            .opacity(0.2)
//                        HStack {
//                            Button(action: {
//                                isShowingCreateVMSheet = true
//                            }, label: {
//                                Image(systemName: "plus")
//                            })
//                            .help("Create a new VM")
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            Button(action: {
//                                let decodedObj = (try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(UserDefaults.standard.data(forKey: VM_name)!) as! VirtualMachineInstance)
//                                viewModel.vm_name = decodedObj.vm_name
//                                viewModel.bootableImageURL = decodedObj.bootableImageURL
//                                viewModel.kernelURL = decodedObj.kernelURL
//                                viewModel.initialRamdiskURL = decodedObj.initialRamdiskURL
//                                viewModel.cpuCount = decodedObj.cpuCount
//                                viewModel.memorySizeinGB = decodedObj.memorySizeinGB
//                                if viewModel.state == nil {
//                                    viewModel.start()
//                                    showConsole()
//                                } else if viewModel.state == .paused {
//                                    if let vm = viewModel.virtualMachine {
//                                        if vm.canResume {
//                                            vm.resume(completionHandler: { _ in })
//                                        }
//                                    }
//                                }
//                            }, label: {
//                                Image(systemName: "play.fill")
//                            })
//                            .help("Run")
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(viewModel.state == .running || VM_name == "")
//                            Button(action: {
//                                if viewModel.state == .running {
//                                    if let vm = viewModel.virtualMachine {
//                                        if vm.canPause {
//                                            vm.pause(completionHandler: { _ in })
//                                        }
//                                    }
//                                }
//                            }, label: {
//                                Image(systemName: "pause.fill")
//                            })
//                            .help("Pause VM")
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(viewModel.state == .paused || VM_name == "" || viewModel.state == nil)
//                            Button(action: {
//                                if let vm = viewModel.virtualMachine {
//                                    if vm.canRequestStop {
//                                        viewModel.stop()
//                                        viewModel.consoleWindowController.close()
//                                        viewModel.state = nil
//                                    }
//                                }
//                            }, label: {
//                                Image(systemName: "square.fill")
//                            })
//                            .help("Stop VM")
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(VM_name == "" || viewModel.state == nil)
//                            Button(action: {
//                                if viewModel.state != nil {
//                                    showConsole()
//                                }
//                            }, label: {
//                                Image(systemName: "eyes.inverse")
//                            })
//                            .help("Show Console")
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(viewModel.state != .running)
//                            Button(action: {
//                                viewModel.writePipe.fileHandleForWriting.write(Data("yes | sudo apt-get install openssh-server\r".utf8))
//                            }, label: {
//                                Image(systemName: "gear")
//                            })
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(viewModel.state != .running)
//                            .help("Install essential tools for the VM")
//                            Button(action: {
//                                viewModel.writePipe.fileHandleForWriting.write(Data("hostname -I | awk '{print $1}'\r".utf8))
//                            }, label: {
//                                Image(systemName: "network")
//                            })
//                            .padding(.top, 15)
//                            .padding(.leading)
//                            .disabled(viewModel.state != .running)
//                            .help("Get IP address of the VM")
//                            Spacer()
//                        }
//                    }
                    Spacer()
                    if VM_name != "" && (UserDefaults.standard.array(forKey: "vms") ?? []).count > 0  {
                        Text("\(VM_name)\nMemory: \(VirtualMachine.getDetails(VM_Name: VM_name, param: 1)) GB\nCPU Count: \(VirtualMachine.getDetails(VM_Name: VM_name, param: 2))")
                    }
                    else {
                        Text("Click on \(Image(systemName:"plus")) to create a new Virtual Machine or\n") + Text("select a VM from the side bar and click on \(Image(systemName: "play.fill")) to run")
                    }
                    Spacer()
                }
                Spacer()
            }.frame(width: 600, height: 400, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .toolbar(content: {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 400, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.top)
                        .opacity(0.2)
                    HStack {
                        Button(action: {
                            isShowingCreateVMSheet = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .help("Create a new VM")
                        .padding(.top, 15)
                        .padding(.leading)
                        Button(action: {
                            let decodedObj = (try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(UserDefaults.standard.data(forKey: VM_name)!) as! VirtualMachineInstance)
                            viewModel.vm_name = decodedObj.vm_name
                            viewModel.bootableImageURL = decodedObj.bootableImageURL
                            viewModel.kernelURL = decodedObj.kernelURL
                            viewModel.initialRamdiskURL = decodedObj.initialRamdiskURL
                            viewModel.cpuCount = decodedObj.cpuCount
                            viewModel.memorySizeinGB = decodedObj.memorySizeinGB
                            if viewModel.state == nil {
                                viewModel.start()
                                showConsole()
                            } else if viewModel.state == .paused {
                                if let vm = viewModel.virtualMachine {
                                    if vm.canResume {
                                        vm.resume(completionHandler: { _ in })
                                    }
                                }
                            }
                        }, label: {
                            Image(systemName: "play.fill")
                        })
                        .help("Run")
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(viewModel.state == .running || VM_name == "")
                        Button(action: {
                            if viewModel.state == .running {
                                if let vm = viewModel.virtualMachine {
                                    if vm.canPause {
                                        vm.pause(completionHandler: { _ in })
                                    }
                                }
                            }
                        }, label: {
                            Image(systemName: "pause.fill")
                        })
                        .help("Pause VM")
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(viewModel.state == .paused || VM_name == "" || viewModel.state == nil)
                        Button(action: {
                            if let vm = viewModel.virtualMachine {
                                if vm.canRequestStop {
                                    viewModel.stop()
                                    viewModel.consoleWindowController.close()
                                    viewModel.state = nil
                                }
                            }
                        }, label: {
                            Image(systemName: "square.fill")
                        })
                        .help("Stop VM")
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(VM_name == "" || viewModel.state == nil)
                        Button(action: {
                            if viewModel.state != nil {
                                showConsole()
                            }
                        }, label: {
                            Image(systemName: "eyes.inverse")
                        })
                        .help("Show Console")
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(viewModel.state != .running)
                        Button(action: {
                            viewModel.writePipe.fileHandleForWriting.write(Data("yes | sudo apt-get install openssh-server\r".utf8))
                        }, label: {
                            Image(systemName: "gear")
                        })
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(viewModel.state != .running)
                        .help("Install essential tools for the VM")
                        Button(action: {
                            viewModel.writePipe.fileHandleForWriting.write(Data("hostname -I | awk '{print $1}'\r".utf8))
                        }, label: {
                            Image(systemName: "network")
                        })
                        .padding(.top, 15)
                        .padding(.leading)
                        .disabled(viewModel.state != .running)
                        .help("Get IP address of the VM")
                        Spacer()
                    }
                }.padding(.leading, 85)
            })
            .sheet(isPresented: $isShowingCreateVMSheet, content: {
                ScrollView {
                    VStack {
                        Group {
                            Text("Virtual Machine Configuration")
                                .font(.title)
                            HStack {
                                TextField("Name ", text: $VM_name)
                                Spacer()
                            }.padding([.leading])
                            .padding([.top, .bottom], 2)
                            HStack {
                                Text("Current configuration :")
                                    .bold()
                                Spacer()
                            }.padding([.leading, .top])
                            HStack {
                                Text("Memory size : \(memorySizeinGB) GB")
                                Spacer()
                            }.padding([.leading])
                            .padding([.top, .bottom], 2)
                            HStack {
                                Text("CPU Count : \(Int(cpuCount))")
                                Spacer()
                            }.padding([.leading])
                            Slider(value: $memorySizeinGB, in: 0.5...Double(Int((VZVirtualMachineConfiguration.maximumAllowedMemorySize / UInt64(memRatioConstant))) - 2), label: {
                                Text("Memory Size")
                            }).padding([.leading,.trailing])
                            Slider(value: $cpuCount, in: 1...Double(HostMachine.getMaximumCpuCount()), label: {
                                Text("CPU Count")
                            }).padding([.leading,.trailing])
                            if HostMachine.machineHardwareName == "arm64" {
                                Button(action: {
                                    
                                }, label: {
                                    Text("Create disk (Optional)")
                                })
                            } else {
                                Text("Note: x86 (Intel) CPU architecture detected\nMake sure you have installed homebrew and installed qemu-image for disk creation to work\nsuccessfully.")
                                    .lineLimit(nil)
                                    .padding([.leading,.trailing])
                                TextField("Name your disk", text: $diskName).padding([.leading,.trailing])
                                Slider(value: $diskSizeinGB, in: 10...Double(1024), label: {
                                    Text("Disk size:\(Int(diskSizeinGB))GB")
                                }).padding([.leading,.trailing])
                                HStack {
                                    Button(action: {
                                        let executableURL = URL(fileURLWithPath: "/usr/local/bin/qemu-img")
                                        let out = Pipe()
                                        let result = Process()
                                        result.executableURL = executableURL
                                        result.arguments = ["create", "-f", "raw", "/Users/\(HostMachine.whoami())/Desktop/\(diskName.count == 0 ? VM_name : diskName)_disk.img", "\(Int(diskSizeinGB))G"]
                                        result.standardOutput = out
                                        try! result.run()
                                    }, label: {
                                        Text("Create disk (Optional)")
                                    }).padding([.leading,.trailing])
                                    Spacer()
                                }
                            }
                            HStack {
                                Button(action: {
                                    let dialog = NSOpenPanel();
                                    dialog.title                   = "Choose all the disks to be attached with the VM";
                                    dialog.showsResizeIndicator    = true;
                                    dialog.showsHiddenFiles        = false;
                                    dialog.allowsMultipleSelection = true;
                                    dialog.canChooseDirectories = false;
                                    dialog.allowedFileTypes = ["img"]
                                    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                                        let result = dialog.urls
                                        
                                        if (result.count > 0) {
                                            for path in result {
                                                HostMachine.disks.append(path)
                                            }
                                        }
                                    } else {
                                        return
                                    }
                                }, label: {
                                    Text("Choose disks")
                                }).padding(.leading)
                                Spacer()
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("vmlinuz: \(viewModel.kernelURL?.lastPathComponent ?? "Drag & Drop here")")
                                    .padding([.top, .bottom, .leading])
                                    .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                                        processDropItem(of: .kernel, items: itemProviders)
                                        return true
                                    }
                                Spacer()
                            }
                            
                            
                            Text("initrd: \(viewModel.initialRamdiskURL?.lastPathComponent ?? "Drag & Drop here")")
                                .padding([.top, .bottom, .leading])
                                .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                                    processDropItem(of: .ramdisk, items: itemProviders)
                                    return true
                                }
                            
                            Text("image: \(viewModel.bootableImageURL?.lastPathComponent ?? "Drag & Drop here")")
                                .padding([.top, .bottom, .leading])
                                .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                                    processDropItem(of: .image, items: itemProviders)
                                    return true
                                }
                            HStack {
                                Button(action: {
                                    viewModel.memorySizeinGB = memorySizeinGB
                                    viewModel.cpuCount = Int(cpuCount)
                                    viewModel.vm_name = VM_name
                                    isShowingCreateVMSheet = false
                                    if viewModel.state == nil {
                                        viewModel.start()
                                        showConsole()
                                    }
                                }, label: {
                                    Label("Run", systemImage: "play")
                                }).padding(.leading)
                                .disabled(!viewModel.isReady)
                                
                                Button(action: {
                                    viewModel.memorySizeinGB = memorySizeinGB
                                    viewModel.cpuCount = Int(cpuCount)
                                    viewModel.vm_name = VM_name
                                    UserDefaults.standard.set(memorySizeinGB, forKey: "\(VM_name)_memsize")
                                    UserDefaults.standard.set(cpuCount, forKey: "\(VM_name)_cpucount")
                                    if HostMachine.disks.count > 0 {
                                        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: HostMachine.disks, requiringSecureCoding: false)
                                        UserDefaults.standard.set(encodedData, forKey: "\(VM_name)_disks_of_vm")
                                        
                                    }
                                    let userDefaults = UserDefaults.standard
                                    var vms: [Any] = userDefaults.array(forKey: "vms") ?? []
                                    vms.append(VM_name)
                                    vms_.append(VM_name)
                                    userDefaults.set(vms, forKey: "vms")
                                    if let encodedData: Data = try? NSKeyedArchiver.archivedData(withRootObject: viewModel, requiringSecureCoding: false) {
                                        userDefaults.set(encodedData, forKey: VM_name)
                                        userDefaults.synchronize()
                                    }
                                    isShowingCreateVMSheet = false
                                }, label: {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                }).padding(.leading)
                                
                                Button(action: { isShowingCreateVMSheet = false }, label: {
                                    Label("Cancel", systemImage: "xmark")
                                }).padding(.leading)
                            }
                        }
                    }.padding()
                }.frame(width: 600, height: 500, alignment: .center)
            })
        } else {
            VStack {
                Text("image: \(viewModel.bootableImageURL?.lastPathComponent ?? "Drag & Drop here")")
                    .padding([.top, .bottom, .leading])
                    .onDrop(of: [.fileURL], isTargeted: nil) { itemProviders -> Bool in
                        processDropItem(of: .image, items: itemProviders)
                        return true
                    }.padding()
                Button(action: {
                    let dialog = NSOpenPanel();
                    dialog.title                   = "Choose all the disks to be attached with the VM";
                    dialog.showsResizeIndicator    = true;
                    dialog.showsHiddenFiles        = false;
                    dialog.allowsMultipleSelection = true;
                    dialog.canChooseDirectories = false;
                    dialog.allowedFileTypes = ["img"]
                    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                        let result = dialog.urls
                        
                        if (result.count > 0) {
                            for path in result {
                                HostMachine.disks.append(path)
                            }
                        }
                    } else {
                        return
                    }
                }, label: {
                    Text("Choose disks")
                }).padding()
                Button("Run", action: {
                    HostMachine.launchQemu(bootableImageURL: viewModel.bootableImageURL!.absoluteString)
                })
            }.frame(width: 400, height: 400, alignment: .center)
        }
    }
}
