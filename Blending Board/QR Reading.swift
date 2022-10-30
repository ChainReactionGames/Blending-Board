//
//  QR Reading.swift
//  Blending Board
//
//  Created by Gary Gogis on 10/2/20.
//

import AVFoundation
import UIKit

@available(macCatalyst 14.0, *)
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!

	@IBOutlet weak var qrCameraView: UIView!
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

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
		let pad = UIDevice.current.userInterfaceIdiom == .pad
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = CGRect(origin: CGPoint(x: 0, y: pad ? 0 : -qrCameraView.bounds.width / 4), size: CGSize(width: qrCameraView.bounds.width, height: qrCameraView.bounds.width))
		previewLayer.videoGravity = .resizeAspectFill
		qrCameraView.layer.addSublayer(previewLayer)

		captureSession.startRunning()
//		if UIDevice.current.userInterfaceIdiom == .pad { return }
		let rotation = UIDevice.current.orientation == .landscapeLeft ? CGFloat.pi * 3 / 2 : CGFloat.pi / 2
		qrCameraView.transform = CGAffineTransform(rotationAngle: pad ? -rotation + .pi : rotation)
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

		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			found(code: stringValue, from: captureSession)
		}

	}

	func found(code: String, from session: AVCaptureSession) {
		print(code)
		if let pack = try? JSONDecoder().decode(LetterPack.self, from: Data(code.utf8)) {
			//AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			captureSession.stopRunning()
			dismiss(animated: true) {
				LetterPack.allPacks.insert(pack, at: 0)
				NotificationCenter.default.post(name: .packChosen, object: pack)
			}
		} else {
			let ac = UIAlertController(title: "Not a Blending Board Deck", message: "This code containes the data: \(code), and is not a Blending Board Deck.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		switch UIDevice.current.orientation {
		case .landscapeLeft:
			return .landscapeLeft
		default:
			return .landscapeRight
		}
	}
	@IBAction func close(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}
extension CIImage {
	/// Inverts the colors and creates a transparent image by converting the mask to alpha.
	/// Input image should be black and white.
	var transparent: CIImage? {
		return inverted?.blackTransparent
	}

	/// Inverts the colors.
	var inverted: CIImage? {
		guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

		invertedColorFilter.setValue(self, forKey: "inputImage")
		return invertedColorFilter.outputImage
	}

	/// Converts all black to transparent.
	var blackTransparent: CIImage? {
		guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
		blackTransparentFilter.setValue(self, forKey: "inputImage")
		return blackTransparentFilter.outputImage
	}

	/// Applies the given color as a tint color.
	func tinted(using color: UIColor) -> CIImage?
	{
		guard
			let transparentQRImage = transparent,
			let filter = CIFilter(name: "CIMultiplyCompositing"),
			let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

		let ciColor = CIColor(color: color)
		colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
		let colorImage = colorFilter.outputImage

		filter.setValue(colorImage, forKey: kCIInputImageKey)
		filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

		return filter.outputImage!
	}
}
