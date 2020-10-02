//
//  QR Reading.swift
//  Blending Board
//
//  Created by Gary Gogis on 10/2/20.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!

	@IBOutlet weak var qrCameraView: UIView!
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = UIColor.black
		captureSession = AVCaptureSession()

		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput

		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}

		if (captureSession.canAddInput(videoInput)) {
			captureSession.addInput(videoInput)
		} else {
			failed()
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()

		if (captureSession.canAddOutput(metadataOutput)) {
			captureSession.addOutput(metadataOutput)

			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = [.qr]
		} else {
			failed()
			return
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		qrCameraView.layer.addSublayer(previewLayer)

		captureSession.startRunning()
	}

	func failed() {
		let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
		captureSession = nil
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if (captureSession?.isRunning == false) {
			captureSession.startRunning()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if (captureSession?.isRunning == true) {
			captureSession.stopRunning()
		}
	}

	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		connection.videoOrientation = .landscapeLeft
		captureSession.stopRunning()

		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			found(code: stringValue)
		}

	}

	func found(code: String) {
		print(code)
		if let pack = try? JSONDecoder().decode(LetterPack.self, from: Data(code.utf8)) {
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			dismiss(animated: true) {
				NotificationCenter.default.post(name: .packChosen, object: pack)
			}
		} else {
			
		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .landscape
	}
	@IBAction func close(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}
