import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class IniciarSesionViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self as GIDSignInDelegate
    }
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user,error) in
            print("Intentando Iniciar Sesion")
            if error != nil {
                self.mostrarAlerta(titulo: "Crear Usuario", mensaje: "El usuario que ingreso no existe. Desea crear uno nuevo?", accion: "Aceptar")
            }else{
                print("Inicio de Sesion Exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
        //GIDSignIn.sharedInstance()?.signIn()
    }
    @IBAction func registrarTapped(_ sender: Any) {
        performSegue(withIdentifier: "registrarSegue", sender: nil)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credential) { (result,error) in
                print("Intentando Iniciar Sesion")
                if error != nil {
                    print("Se ha generado el siguiente error: \(error)")
                }else{
                    print("Se ha iniciado exitosamente la sesion")
                }
            }
        }
    }
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCEL = UIAlertAction(title: "Cancelar", style: .default, handler: {(UIAlertAction) in return})
        let btnOK = UIAlertAction(title: "Crear", style: .default, handler: {(UIAlertAction) in self.performSegue(withIdentifier: "registrarSegue", sender: nil)})
        alerta.addAction(btnOK)
        alerta.addAction(btnCANCEL)
        present(alerta, animated: true, completion: nil)
    }
}
