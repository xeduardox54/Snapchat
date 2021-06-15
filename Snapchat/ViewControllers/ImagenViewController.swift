import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioID = NSUUID().uuidString
    var audioURL:URL?
    var cargarAudioURL:URL?

    @IBOutlet weak var grabar: UIButton!
    @IBOutlet weak var reproducir: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        configurarGrabacion()
    }
    
    func configurarGrabacion(){
           do{
               let session = AVAudioSession.sharedInstance()
               try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
               try session.overrideOutputAudioPort(.speaker)
               try session.setActive(true)
               
               let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
               let pathComponents = [basePath, "audio.m4a"]
               audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
               
               print("*************************")
               print(audioURL!)
               print("*************************")
               
               var settings:[String:AnyObject] = [:]
               settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
               settings[AVSampleRateKey] = 44100.0 as AnyObject?
               settings[AVNumberOfChannelsKey] = 2 as AnyObject?
               
               grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
               grabarAudio!.prepareToRecord()
           }catch let error as NSError{
               print(error)
           }
       }

    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabar.setTitle("GRABAR", for: .normal)
            reproducir.isEnabled = true
        }else{
            grabarAudio?.record()
            grabar.setTitle("DETENER", for: .normal)
            reproducir.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        
        let audioFolder = Storage.storage().reference().child("audios")
        let cargarAudio = audioFolder.child("\(audioID).mp3")
        cargarAudio.putFile(from: audioURL!, metadata: nil){ (metadata,error) in
            if error != nil {
                self.mostrarAlerta(titulo: "ERROR", mensaje: "Se produjo un error al subir el audio. Verifique su conexion a internet y vuelva a intentarlo", accion: "Aceptar")
                print("Ocurrio un error al subir audio \(error)")
                return
            }else{
                cargarAudio.downloadURL(completion: {(url, error) in
                    guard let enlaceURL = url else{
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener informacion de audio", accion: "Cancelar")
                        print("Ocurrio un error al subir audio: \(error)")
                        return
                    }
                    self.cargarAudioURL = url
                })
            }
        }
        
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        cargarImagen.putData(imagenData!, metadata: nil) { (metadata,error) in
            if error != nil {
                self.mostrarAlerta(titulo: "ERROR", mensaje: "Se produjo un error al subir la imagen. Verifique su conexion a internet y vuelva a intentarlo", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrio un error al subir imagen \(error)")
                return
            }else{
                cargarImagen.downloadURL(completion: {(url, error) in
                    guard let enlaceURL = url else{
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener informacion de imagen", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrio un error al subir imagen: \(error)")
                        return
                }
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
            })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioURL = cargarAudioURL!.absoluteString
        siguienteVC.audioID = audioID
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
    
}
