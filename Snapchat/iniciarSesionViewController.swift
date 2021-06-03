import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class IniciarSesionViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self as GIDSignInDelegate
    }
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
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
}
