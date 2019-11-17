'use strict';

const fs = require('fs');
const conferences = require("./conference.json")
const talks = require("./_talk.json")
const speakers = require("./speaker.json")


const crypto = require("crypto");
const id = crypto.randomBytes(20).toString("hex");

var newTalks = []
var newSpeaker = []

for (var talkIndex in talks) {
    var talk = talks[talkIndex]
    
    var oldId = talk.id
    talk.id = crypto.randomBytes(20).toString("hex");

    for (var speakerIndex in speakers) {
        var speaker = speakers[speakerIndex]

        if (talk.speakerId == speaker.id) {
            talk.speakerId = crypto.randomBytes(20).toString("hex");
            speaker.id = talk.speakerId

            newTalks.push(talk)
            newSpeaker.push(speaker)
        }
    }
}

console.log(newTalks[1])

fs.writeFile ("_speaker.json", JSON.stringify(newSpeaker), function(err) {
    if (err) throw err;
    console.log('complete');
    }
);

fs.writeFile ("__talk.json", JSON.stringify(newTalks), function(err) {
    if (err) throw err;
    console.log('complete');
    }
);