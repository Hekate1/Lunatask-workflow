#!/usr/bin/python3

import sys
import os
import json

addFooter = True
printList = False

assert "createTaskState" in os.environ
output = {}
varNames = ["taskName", "areaIdx", "goalIdx", "taskStatus", "taskEstimate", "taskPriority"]
varsDict = {}

for name in varNames:
    if name in os.environ:
        varsDict[name] = os.environ[name]

if os.environ["createTaskState"] != "0":
    output["response"] = f"\n\n{sys.argv[1]}\n--------\n\n"

if os.environ["createTaskState"] == "0":
    varsDict["createTaskState"] = "1"
    output["response"] = "Please enter the name of the task"

elif os.environ["createTaskState"] == "1":
    varsDict["createTaskState"] = "2"
    varsDict["taskName"] = sys.argv[1]
    output["response"] += "Please select the task area by number:"
    idx = 1
    while f"area{idx}" in os.environ and os.environ[f"area{idx}"] != "":
        output["response"] += f"\n{idx}: {os.environ[f'area{idx}'].split(':')[0]}"
        idx += 1

elif os.environ["createTaskState"] == "2":
    candidateArea = f"area{sys.argv[1]}"
    if candidateArea in os.environ and os.environ[candidateArea] != "":
        varsDict["areaIdx"] = sys.argv[1]
        printList = True
    else:
        varsDict["createTaskState"] = "2"
        output["response"] += "Invalid area number, please try again"

elif os.environ["createTaskState"] == "3":
    if sys.argv[1] == "1":
        output["response"] = ""
        output["actionoutput"] = "true"
        addFooter = False
    elif sys.argv[1] == "2":
        possibleGoals = []
        idx = 1
        while f"goal{idx}" in os.environ and os.environ[f"goal{idx}"] != "":
            if os.environ[f"goal{idx}"].split(":")[0] == os.environ[f"area{os.environ['areaIdx']}"].split(":")[0]:
                possibleGoals.append(os.environ[f"goal{idx}"].split(":")[1])
            idx += 1
        if len(possibleGoals) > 0:
            varsDict["createTaskState"] = "4"
            output["response"] += "Please select the goal by number:\n0. Cancel"
            printIdx = 1
            for goal in possibleGoals:
                output["response"] += f"\n{printIdx}. {goal}"
                printIdx += 1
        else:
            varsDict["createTaskState"] = "3"
            output["response"] += "No goals in area of life, please select a new option"
    elif sys.argv[1] == "3":
        varsDict["createTaskState"] = "8"
        output["response"] = "note"
        output["actionoutput"] = "true"
        addFooter = False
    elif sys.argv[1] == "4":
        varsDict["createTaskState"] = "5"
        output["response"] += "Please select the status by number:\n0. Cancel\n1. Later (default)\n2. Next\n3. Started\n4. Waiting\n5. Completed"
    elif sys.argv[1] == "5":
        varsDict["createTaskState"] = "6"
        output["response"] += "Please enter the time estimate in minutes, enter 0 to cancel"
    elif sys.argv[1] == "6":
        varsDict["createTaskState"] = "7"
        output["response"] += "Please select the priority by number:\n0. Cancel\n1. Lowest priority\n2. Low priority\n3. Normal priority (default)\n4. High priority\n5. Highest priority"
    else:
        varsDict["createTaskState"] = "3"
        output["response"] += "Invalid selection, please try again"

elif os.environ["createTaskState"] == "4":
    selection = sys.argv[1]
    if selection == "0":
        printList = True
    else:
        idxMapping = {}
        idx = 1
        selectionIdx = 1
        while f"goal{idx}" in os.environ and os.environ[f"goal{idx}"] != "":
            if os.environ[f"goal{idx}"].split(":")[0] == os.environ[f"area{os.environ['areaIdx']}"].split(":")[0]:
                idxMapping[str(selectionIdx)] = idx
                selectionIdx += 1
            idx += 1

        if selection in idxMapping:
            varsDict["goalIdx"] = selection
            printList = True
        else:
            varsDict["createTaskState"] = "4"
            output["response"] += "Invalid goal number, please try again"

elif os.environ["createTaskState"] == "5":
    selection = sys.argv[1]
    if selection in ["0", "1", "2", "3", "4", "5"]:
        printList = True
        
    if selection == "1":
        varsDict["taskStatus"] = "later"
    elif selection == "2":
        varsDict["taskStatus"] = "next"
    elif selection == "3":
        varsDict["taskStatus"] = "started"
    elif selection == "4":
        varsDict["taskStatus"] = "waiting"
    elif selection == "5":
        varsDict["taskStatus"] = "completed"
    elif selection != "0":
        varsDict["createTaskState"] = "5"
        output["response"] += "Invalid status selection, please try again"

elif os.environ["createTaskState"] == "6":
    if sys.argv[1].isdigit():
        if sys.argv[1] == "0":
            printList = True
        else:
            varsDict["taskEstimate"] = sys.argv[1]
            printList = True
    else:
        varsDict["createTaskState"] = "6"
        output["response"] += "Invalid time estimate, please try again"
    
elif os.environ["createTaskState"] == "7":
    selection = sys.argv[1]
    if selection in ["0", "1", "2", "3", "4", "5"]:
        printList = True
        
    if selection == "1":
        varsDict["taskPriority"] = "-2"
    elif selection == "2":
        varsDict["taskPriority"] = "-1"
    elif selection == "3":
        varsDict["taskPriority"] = "0"
    elif selection == "4":
        varsDict["taskPriority"] = "1"
    elif selection == "5":
        varsDict["taskPriority"] = "2"
    elif selection != "0":
        varsDict["createTaskState"] = "5"
        output["response"] += "Invalid priority selection, please try again"

elif os.environ["createTaskState"] == "8":
    output["response"] = ""
    printList = True

if printList:
    varsDict["createTaskState"] = "3"
    output["response"] += "Please select an option by number\n\n1. Done\n2. Attach to goal\n3. Attach note\n4. Change status\n5. Add time estimate\n6. Add priority"

if addFooter:
    output["footer"] = "Task Creation"
    output["behaviour"] = {
        "response": "append",
        "scroll": "auto",
        "inputfield": "clear"
    }

output["variables"] = varsDict
sys.stdout.write(json.dumps(output))