'use strict';

const fs = require('fs');
const { exec } = require('child_process');
const ytdl = require('ytdl-core');
var youtubedl = require('youtube-dl');
var request = require('request');
const download = require('image-downloader');
const json = require("../../_data/talk.json");

var index
var talk
var min = 0;
var max = 58;

exec("ls ../../images/preview", { "shell": "/bin/zsh", maxBuffer: 1024 * 1024 }, function (error, files) {

    for (index in json) {
        let talk = json[index]
        let id = talk.videoId
    
        if (id != "") {
            var random = Math.floor(Math.random() * (max - min + 1)) + min;
            
            if (!files.includes(id)) {
                console.log("downloading")
                if (talk.source.includes("youtube")) {
                    
                    ytdl.getInfo(id, (err, info) => {
                        if (err) { console.log("error for id:" + id)};

                        let format = ytdl.chooseFormat(info.formats, { quality: 'highest' });

                        if (format) {
                            
                            let command = `ffmpeg -i "${format.url}"  -r 1 -t 1 -ss  00:02:${random} ../../images/preview/previewImage-${id}.jpeg`
                            
                            exec(command, { "shell": "/bin/zsh" }, function (error, done) {
                                if (error) {
                                    console.log("error " + id )
                                } else {
                                    console.log("success")
                                }                                
                            });
                        } else {
                            console.log("format not found")
                        }
                    });
                } else {
                    let url = "https://vimeo.com/" + id

                    youtubedl.getInfo(url, null, { maxBuffer: Infinity } , (err, info) => {
                        if (err) { console.log(err); return}

                        let thumbnail = info.thumbnail

                        if (thumbnail) {
                            var command = `curl -o ../../images/preview/previewImage-${id}.jpeg  ${thumbnail} -O -s &`
                            
                            exec(command, { "shell": "/bin/zsh" }, function (stdout, stderr) {
                                console.log("downloaded with curl")
                            });
                            
                        } else {
                            let command = `ffmpeg -i "${info.url}"  -r 1 -t 1 -ss  00:00:${random} ../../images/preview/previewImage-${id}.jpeg`

                            exec(command, { "shell": "/bin/zsh" }, function (stdout, stderr) {
                                console.log("downloading vimeo with ffmpeg")
                            });
                        }
                        
                    });
                }
            } else {
                console.log("exists")
            }
        }
    }
});
