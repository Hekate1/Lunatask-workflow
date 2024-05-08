#!/usr/bin/python3

import sys
import os
import json

addFooter = True

assert "createNoteState" in os.environ
output = {}
varNames = ["noteName", "notebookIdx"]
varsDict = {}

for name in varNames:
    if name in os.environ:
        varsDict[name] = os.environ[name]

if os.environ["createNoteState"] != "0":
    output["response"] = f"\n\n{sys.argv[1]}\n--------\n\n"

if os.environ["createNoteState"] == "0":
    varsDict["createNoteState"] = "1"
    output["response"] = "Please enter the name of the note"

elif os.environ["createNoteState"] == "1":
    varsDict["createNoteState"] = "2"
    varsDict["noteName"] = sys.argv[1]
    output["response"] += "Please select the notebook by number:"
    idx = 1
    while f"notebook{idx}" in os.environ and os.environ[f"notebook{idx}"] != "":
        output["response"] += f"\n{idx}: {os.environ[f'notebook{idx}'].split(':')[0]}"
        idx += 1

elif os.environ["createNoteState"] == "2":
    candidateNotebook = f"notebook{sys.argv[1]}"
    if candidateNotebook in os.environ and os.environ[candidateNotebook] != "":
        varsDict["notebookIdx"] = sys.argv[1]
        output["response"] = ""
        output["actionoutput"] = "true"
        addFooter = False
    else:
        varsDict["createNoteState"] = "2"
        output["response"] += "Invalid notebook number, please try again"

if addFooter:
    output["footer"] = "Note Creation"
    output["behaviour"] = {
        "response": "append",
        "scroll": "auto",
        "inputfield": "clear"
    }

output["variables"] = varsDict
sys.stdout.write(json.dumps(output))