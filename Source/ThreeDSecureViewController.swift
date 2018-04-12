// Copyright 2018 Brightec Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

public class ThreeDSecureViewController: UIViewController {

    private var config: ThreeDSecureConfig?
    public var delegate: ThreeDSecureViewDelegate?

    public convenience init(config: ThreeDSecureConfig) {
        self.init(nibName: nil, bundle: nil)
        self.config = config
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let threeDSecureView = ThreeDSecureView(frame: .zero)
        threeDSecureView.delegate = delegate

        view.addSubview(threeDSecureView)
        threeDSecureView.translatesAutoresizingMaskIntoConstraints = false
        threeDSecureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        threeDSecureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        threeDSecureView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        threeDSecureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        if let config = config {
            threeDSecureView.start3DSecure(config: config)
        }
    }

}
