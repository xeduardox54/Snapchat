import UIKit

class VerSnapViewController: UIViewController {

    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje :" + snap.descrip

    }

}
