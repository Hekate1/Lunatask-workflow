#!/usr/bin/swift

import SwiftUI
import Foundation

struct TaskForm: View {
    let areas: Array<String>
    let goals: Array<String>
    @State var taskName: String = ""
    @State var areaIdx: String = "1"
    @State var goalIdx: String = "0"
    @State var taskStatus: String = "later"
    @State var taskPriority: String = "0"
    @State var taskEstimate: String = ""
    @State var taskNote: String = ""
    @State var bottomText: String = "Items with a * are required"
    
    var body: some View {
        VStack {
            Text("Create task in Lunatask").font(.title2)
            Row(text: "Task Name *", input: $taskName)
            AreaAndGoalSelector(areaIdx: $areaIdx, goalIdx: $goalIdx, areas: areas, goals: goals)
            Selector(title: "Status", selection: $taskStatus, options: ["Later (default):later", "Next:next", "In progress:started", "Waiting:waiting", "Completed:completed"])
            Selector(title: "Priority", selection: $taskPriority, options: ["Highest priority:2", "High priority:1", "Normal priority (default):0", "Low priority:-1", "Lowest priority:-2"])
            Row(text: "Estimate in minutes", input: $taskEstimate)
            HStack {
                VStack {
                    Text("Task Note\n")
                    Text("Enter your text")
                    Text("in markdown")
                }
                
                TextEditor(text: $taskNote).frame(maxWidth: 300, minHeight: 100).font(.custom("HelveticaNeue", size: 13))
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
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
                // print("\(title)\t\(text)\t\(max)\t\(min)\t\(long)\t\(areaOfLife)\t\(toggle.description)")
                // ["taskName", "areaIdx", "goalIdx", "taskStatus", "taskEstimate", "taskPriority"]
                if (goalIdx == "0") {
                    goalIdx = ""
                }
                if (taskName.contains("swiftseperator") || taskNote.contains("swiftseperator")) {
                    bottomText = "The string 'swiftseperator' cannot be in the task name or note"
                }
                else if (taskName == "") {
                    bottomText = "'Task Name' cannot be empty"
                }
                else if (taskEstimate != "" && Int(taskEstimate) == nil) {
                    bottomText = "The estimate field must be an integer"
                }
                else {
                    let otherVars: Array<String> = [areaIdx, goalIdx, taskStatus, taskPriority, taskEstimate, taskNote]
                    var outputText: String = taskName
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

struct AreaAndGoalSelector: View {
    @Binding var areaIdx: String
    @Binding var goalIdx: String
    let areas: Array<String>
    let goals: Array<String>
    func GoalsInArea() -> Array<String> {
        var matchingGoals: Array<String> = ["None:0"]
        let areaName: String = String(areas[Int(areaIdx)! - 1].split(separator: ":")[0])
        for goal: String in goals {
            if (String(goal.split(separator: ":")[0]) == areaName) {
                matchingGoals.append(String(goal.split(separator: ":")[1] + ":" + goal.split(separator: ":")[2]))
            }
        }
        goalIdx = "0"
        return matchingGoals
    }
    @State var goalOptions: Array<String> = []
    var areaOfLifePicker: some View {
        HStack {
            Text("Areas of Life *")
            Picker("", selection: $areaIdx, content: {
                ForEach(areas, id: \.self) {op in Text(String(op.split(separator: ":")[0])).tag(String(op.split(separator: ":")[1]))}
            })
            .frame(width: 300)
            .onChange(of: areaIdx, initial: true, {goalOptions = GoalsInArea()})
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    var goalPicker: some View {
        HStack {
            Text("Attached Goal")
            Picker("", selection: $goalIdx, content: {
                ForEach(goalOptions, id: \.self) {op in Text(String(op.split(separator: ":")[0])).tag(String(op.split(separator: ":")[1]))}
            })
            .frame(width: 300)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    var body: some View {
        VStack {
            areaOfLifePicker
            goalPicker
        }
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
    var areas: Array<String>
    var goals: Array<String>
    var window: NSWindow!
    init(areas: Array<String>, goals: Array<String>) {
        self.areas = areas
        self.goals = goals
    }

    final func applicationDidFinishLaunching(_ aNotification: Notification) {
        let taskFormView = TaskForm(areas: areas, goals: goals)
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
var areas: Array<String> = []
while (env["area" + String(idx)] != nil && env["area" + String(idx)] != "") {
    areas.append(String((env["area" + String(idx)]!).split(separator: ":")[0]) + ":" + String(idx))
    idx += 1
}

idx = 1
var goals: Array<String> = []
while (env["goal" + String(idx)] != nil && env["goal" + String(idx)] != "") {
    let goal = (env["goal" + String(idx)]!).split(separator: ":")
    goals.append(String(goal[0]) + ":" + String(goal[1]) + ":" + String(idx))
    idx += 1
}

let app = NSApplication.shared
let delegate = TaskFormAppDelegate(areas: areas, goals: goals)
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
