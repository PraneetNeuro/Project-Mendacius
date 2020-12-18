//
//  ConsoleViewController.swift
//  Project Mendacius
//
//  Created by Praneet S and Meghana Khuntia on 26/11/20.
//

import Foundation
import Cocoa
import SwiftTerm

class ConsoleViewController: NSViewController, TerminalViewDelegate {
    
    private lazy var terminalView: TerminalView = {
        let terminalView = TerminalView()
        terminalView.translatesAutoresizingMaskIntoConstraints = false
        terminalView.terminalDelegate = self
        if UserDefaults.standard.value(forKey: "vmbg_r") == nil && UserDefaults.standard.value(forKey: "vmbg_g") == nil && UserDefaults.standard.value(forKey: "vmbg_b") == nil && UserDefaults.standard.value(forKey: "vmfg_r") == nil && UserDefaults.standard.value(forKey: "vmfg_g") == nil && UserDefaults.standard.value(forKey: "vmfg_b") == nil {
            UserDefaults.standard.set(0, forKey: "vmbg_r")
            UserDefaults.standard.set(0, forKey: "vmbg_g")
            UserDefaults.standard.set(0, forKey: "vmbg_b")
            UserDefaults.standard.set(35389, forKey: "vmfg_r")
            UserDefaults.standard.set(35389, forKey: "vmfg_g")
            UserDefaults.standard.set(35389, forKey: "vmfg_b")
        }
        let bgColor = Color(red: UInt16(UserDefaults.standard.integer(forKey: "vmbg_r")), green: UInt16(UserDefaults.standard.integer(forKey: "vmbg_g")), blue: UInt16(UserDefaults.standard.integer(forKey: "vmbg_b")))
        let fgColor = Color(red: UInt16(UserDefaults.standard.integer(forKey: "vmfg_r")), green: UInt16(UserDefaults.standard.integer(forKey: "vmfg_g")), blue: UInt16(UserDefaults.standard.integer(forKey: "vmfg_b")))
        terminalView.setBackgroundColor(source: terminalView.getTerminal(), color: bgColor)
        terminalView.setForegroundColor(source: terminalView.getTerminal(), color: fgColor)
        return terminalView
    }()
    
    private var readPipe: Pipe?
    private var writePipe: Pipe?
    
    override func loadView() {
        view = NSView()
    }
    
    deinit {
        readPipe?.fileHandleForReading.readabilityHandler = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(terminalView)
        NSLayoutConstraint.activate([
            terminalView.topAnchor.constraint(equalTo: view.topAnchor),
            terminalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            terminalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            terminalView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configure(with readPipe: Pipe, writePipe: Pipe) {
        self.readPipe = readPipe
        self.writePipe = writePipe
        readPipe.fileHandleForReading.readabilityHandler = { [weak self] pipe in
            let data = pipe.availableData
            if let strongSelf = self {
                DispatchQueue.main.sync {
                    strongSelf.terminalView.feed(byteArray: [UInt8](data)[...])
                }
            }
        }
    }
    
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
    }
    
    func setTerminalTitle(source: TerminalView, title: String) {
        
    }
    
    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        writePipe?.fileHandleForWriting.write(Data(data))
    }
    
    func scrolled(source: TerminalView, position: Double) {

    }
}
