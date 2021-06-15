import UIKit
import AVFoundation
import SDWebImage
import Firebase

class VerSnapViewController: UIViewController {

    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var audioButton: UIButton!
    var snap = Snap()
    var audioPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje: " + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
    }
    
    @IBAction func audioButtonTapped(_ sender: Any) {
        let audioUrlStr = snap.audioURL
        print(audioUrlStr)
        if let url = URL(string: audioUrlStr) {
           do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
              audioPlayer = try AVAudioPlayer(data: Data(contentsOf: url))
              audioPlayer!.volume = 2.0
              audioPlayer!.prepareToPlay()
              print("Audio ready to play")
              audioPlayer!.play()
           } catch let error {
                print("error occured while audio downloading")
                print(error.localizedDescription)
           }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{(error) in print("Se elimino la imagen correctamente")}
        
        Storage.storage().reference().child("audios").child("\(snap.audioID).mp3").delete{(error) in print("Se elimino el audio correctamente")}
    }

}
