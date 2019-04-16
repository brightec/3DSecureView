<p align="center">
  <img width="100" src="https://github.com/brightec/.github/blob/master/brighteclogo2018.svg">
</p>
<br/>

# ThreeDSecureView

ThreeDSecureView is primarily a WKWebView that handles the 3DSecure payment process by sending a POST request to the provided card issuer URL with the MD and PaReq parameters set. The WKWebView then intercepts the POST response from the card issuer, extracts the MD and PaRes values and passes them back to your app.

## Requirements

 - iOS 9.0+
 - Swift 4.0

## Installation

### CocoaPods

    pod 'ThreeDSecureView', '~> 1.0.0'

## Usage

### Easy

The easiest way to use ThreeDSecureView is to instantiate ThreeDSecureViewController and present it in a UINavigationController.

    let config = ThreeDSecureConfig(md: "YOUR MD", paReq: "YOUR PAREQ", cardUrl: "YOUR CARD URL")
    let viewController = ThreeDSecureViewController(config: config)
    viewController.delegate = self // Implement ThreeDSecureViewDelegate

    let navController = UINavigationController(rootViewController: viewController)
    present(navController, animated: true, completion: nil)

Handle the callbacks:

    extension YourViewController: ThreeDSecureViewDelegate {

        func threeDSecure(view: ThreeDSecureView, md: String, paRes: String) {
            // Handle success here
        }

        func threeDSecure(view: ThreeDSecureView, error: Error) {
            // Handle errors here
        }

    }

### Advanced

If you don't want to use the provided UIViewController, you can just instantiate ThreeDSecureView directly, add it to your view hierarchy and call start3DSecure() yourself.

## License

See [license](LICENSE)

## Author

This repo is maintained by the [Brightec](https://www.brightec.co.uk/) team

