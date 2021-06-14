import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegistrarViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func regresarTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
            print("Intentando crear un usuario")
            if error != nil{
                print("Se presento el siguiente error al crear el usuario: \(error)")
            }else{
                print("El usuario fue creado exitosamente")
                Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                let alerta = UIAlertController(title: "Creacion de Usuario", message: "Usuario: \(self.emailTextField.text!) se creo correctamente", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
            }
        })
    }
}
