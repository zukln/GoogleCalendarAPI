import UIKit
import AppAuth
import Alamofire
import GTMAppAuth
import SwiftyJSON

class ViewController: UIViewController {
    
    private let scopes = ["https://www.googleapis.com/auth/calendar","https://www.googleapis.com/auth/calendar.readonly","https://www.googleapis.com/auth/calendar.events","https://www.googleapis.com/auth/calendar.events.readonly"]
    private let kClientID = "クライアントIDを入力"
    private let kRedirectURL = URL.init(string: "リバースクライアントIDを入力:/oauthredirect")
    private let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
    private var authorization: GTMAppAuthFetcherAuthorization?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = OIDAuthorizationRequest.init(configuration: configuration,
                                                   clientId: kClientID,
                                                   scopes: self.scopes,
                                                   redirectURL: kRedirectURL!,
                                                   responseType: OIDResponseTypeCode,
                                                   additionalParameters: nil)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        print("Initiating authorization request with scope: \(request.scope!)")
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request,
                                                                      presenting: self,
                                                                      callback: { (authState, error) in if (authState != nil) {
                                                                        // 認証情報オブジェクトを生成
                                                                        self.authorization = GTMAppAuthFetcherAuthorization.init(authState: authState!)
                                                                        let accessToken = authState?.lastTokenResponse?.accessToken
                                                                        print("Authorization トークンを取得しました：\(String(describing: accessToken))")
                                                                        
                                                                        }
        })
    }
    
    
    @IBAction func getAPI(_ sender: Any) {
        Alamofire.request("https://www.googleapis.com/calendar/v3/calendars/メールアドレス/events?key=あなたのAPIキーを入力", method:.get)
            .responseJSON{response in
                let json = JSON(response.result.value)
                json["items"].forEach{(_, data) in
                    let summary = data["summary"].string
                    print(summary)
                    print("イベントの取得に成功しました。")
                }
        }
    }
}
