#!/usr/bin/swift

import SwiftUI
import Foundation

struct TaskForm: View {
    let notebooks: Array<String>
    @State var noteName: String = ""
    @State var notebookIdx: String = "1"
    @State var bottomText: String = "Items with a * are required"
    
    var body: some View {
        VStack {
            Text("Create note in Lunatask").font(.title2)
            Row(text: "Note Name *", input: $noteName)
            Selector(title: "Notebook *", selection: $notebookIdx, options: notebooks)
            Buttons()
            Text(bottomText)
        }
        .padding()
        .frame(width: 460)
    }
    
    @ViewBuilder
    func Buttons() -> some View {
        HStack {
            Button(role: .cancel) {
                print("canceled", terminator: "")
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Cancel")
            }
            // ===---------------------------------------------------------------=== //
            // MARK: - Define here what should be returned
            // ===---------------------------------------------------------------=== //
            Button {
                if (noteName.contains("swiftseperator")) {
                    bottomText = "The string 'swiftseperator' cannot be in the note name"
                }
                else if (noteName == "") {
                    bottomText = "'Note Name' cannot be empty"
                }
                else {
                    let otherVars: Array<String> = [notebookIdx]
                    var outputText: String = noteName
                    for taskVar: String in otherVars {
                        outputText += "swiftseperator" + taskVar
                    }
                    print(outputText, terminator: "")
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Text("Proceed")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 10)
    }
}

struct Row: View {
    let text: String
    @Binding var input: String
    
    var body: some View {
        HStack {
            Text(text)
            TextField("", text: $input)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct Selector: View {
    let title: String
    @Binding var selection: String
    let options: Array<String>
    var body: some View {
        HStack {
            Text(title)
            Picker("", selection: $selection, content: {
                ForEach(options, id: \.self) {op in Text(String(op.split(separator: ":")[0])).tag(String(op.split(separator: ":")[1]))}
            })
            .frame(width: 300)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

final class TaskFormAppDelegate: NSObject, NSApplicationDelegate {
    var notebooks: Array<String>
    var window: NSWindow!
    init(notebooks: Array<String>) {
        self.notebooks = notebooks
    }

    final func applicationDidFinishLaunching(_ aNotification: Notification) {
        let taskFormView = TaskForm(notebooks: notebooks)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 350),
            styleMask: [.titled, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.collectionBehavior = .canJoinAllSpaces
        window.level = NSWindow.Level.floating
        window.contentView = NSHostingView(rootView: taskFormView)
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

let env: [String : String] = ProcessInfo.processInfo.environment
var idx: Int = 1
var notebooks: Array<String> = []
while (env["notebook" + String(idx)] != nil && env["notebook" + String(idx)] != "") {
    notebooks.append(String((env["notebook" + String(idx)]!).split(separator: ":")[0]) + ":" + String(idx))
    idx += 1
}

let app = NSApplication.shared
let delegate = TaskFormAppDelegate(notebooks: notebooks)
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
