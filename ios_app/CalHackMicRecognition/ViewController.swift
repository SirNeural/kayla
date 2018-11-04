//
//  ViewController.swift
//  CalHackMicRecognition
//
//  Created by Jack Feng on 11/2/18.
//  Copyright © 2018 Jack Feng. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices


class ViewController: UIViewController, AVAudioRecorderDelegate {

    var recordSession: AVAudioSession!
    var recorder:AVAudioRecorder!

    //when audioRecorder == nil, means no audioRecorder, we build a recorder
    let recordID = 0

    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var record1TextField: UITextField!
    @IBOutlet weak var record2TextField: UITextField!


    @IBAction func record(_ sender: Any) {
        var fileName = URL(string: "default")!
        //Check if we have an active recorder
        if recorder == nil{
            fileName = getDirectory().appendingPathComponent("voice.m4a")

            //a array "setting" contains all of the settings
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue]

            //start audio recording
            do{
                recorder = try AVAudioRecorder(url: fileName, settings: settings)
                recorder.delegate = self
                recorder.record()
                recordButton.setTitle("Stop", for: .normal)
            }
            catch{
                displayAlert(title: "RecordError ", message: "Fail @ start audio recording")
            }


        }else{
            //we already have audio recording
            //Stopping audio recording
            recorder.stop()
            //print(recorder.url)

            //save the recording
            

            recordButton.setTitle("Record", for: .normal)

            //uploadRequest()

            upload(recorder.url)
            print("finished")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Setting up session

        //initialize recording session
        recordSession = AVAudioSession.sharedInstance()

        //ask for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("ACCEPTED")
            }
        }
    }


    //Function that gets path to directory(where we're going to save the audio)
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    //Function that display an alert
    func displayAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //push the file to the server(backend)

    func upload(_ fileUrl: URL){


        let record: Data? = try? Data(contentsOf: fileUrl)

        let url = URL(string: "https://00481beb.ngrok.io/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let uploadData = record{
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        print ("server error")
                        return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                }
            }
            task.resume()
        }
    }
}


//
//    /// Create request
//    ///
//    /// - parameter userid:   The userid to be passed to web service
//    ///
//    /// - returns:            The `URLRequest` that was created
//
//    func createRequest(fileUrl: URL) throws -> URLRequest {
//        let boundary = generateBoundaryString()
//
//        let url = URL(string: "http://517e4a04.ngrok.io/upload")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        //print(path1)
//        request.httpBody = try createBody(filePathKey: "file", url: fileUrl, boundary: boundary)
//
//        return request
//    }
//
//    private func createBody(filePathKey: String, url: URL, boundary: String) throws -> Data {
//        var body = Data()
//
//        let filename = url.lastPathComponent
//        let data = try Data(contentsOf: url)
//        let mimetype = mimeType(for: url)
//
//        body.append("--\(boundary)\r\n")
//        body.append("Content-Disposition: form-data; filename=\"\(filename)\"\r\n")
//        body.append("Content-Type: \(mimetype)\r\n\r\n")
//        body.append(data)
//        body.append("\r\n")
//
//        body.append("--\(boundary)--\r\n")
//        return body
//    }
//
//    /// Create boundary string for multipart/form-data request
//    ///
//    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
//
//    private func generateBoundaryString() -> String {
//        return "Boundary-\(UUID().uuidString)"
//    }
//
//    /// Determine mime type on the basis of extension of a file.
//    ///
//    /// This requires `import MobileCoreServices`.
//    ///
//    /// - parameter path:         The path of the file for which we are going to determine the mime type.
//    ///
//    /// - returns:                Returns the mime type if successful. Returns `application/octet-stream` if unable to determine mime type.
//
//    private func mimeType(for url: URL) -> String {
//        let pathExtension = url.pathExtension
//
//        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
//            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
//                return mimetype as String
//            }
//        }
//        return "application/octet-stream"
//    }
//}
//
//extension Data {
//
//    /// Append string to Data
//    ///
//    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
//    ///
//    /// - parameter string:       The string to be added to the `Data`.
//
//    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
//        if let data = string.data(using: encoding) {
//            append(data)
//        }
//    }
//}
//
//
//
//
//
//
//
//
//
////let url = NSURL(string: "http://517e4a04.ngrok.io/upload")!
////var request = NSURLRequest(url: <#T##URL#>)
//
//
////
////        let myUrl = URL(string: "http://517e4a04.ngrok.io/upload")!
////        var myRequest = URLRequest(url:myUrl)
////        myRequest.httpMethod = "POST"
////
////        let boundary = generateBoundaryString()
////        myRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
////
////        let file = "Voice1.m4a"
////        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
////
////            let fileURL = dir.appendingPathComponent(file)
////
////            //reading
////            do {
////                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
////            }
////            catch {/* error handling here */}
////        }
////
////        let audioData = try? Data.init(contentsOf: getDirectory().appendingPathComponent("Voice1.m4a"))
////
////        if(audioData==nil)  { return; }
////        print(audioData)
////        myActivityIndicator.startAnimating();
////
////        //dataTaskWithRequest
////        if let rawData = audioData {
////            let task = URLSession.shared.uploadTask(with: myRequest, from: rawData) { (data, response, error) in
////                print("upload finished")
////            }
////            task.resume()
////        }
////    }
////
////    private func generateBoundaryString() -> String {
////        return "Boundary-\(UUID().uuidString)"
////    }
