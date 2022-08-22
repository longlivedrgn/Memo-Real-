//
//  ComposeViewController.swift
//  Memo
//
//  Created by 김용재 on 2022/08/12.
//

import UIKit

class ComposeViewController: UIViewController {
    
    var editTarget: Memo?
    
    // 편집 이전의 메모 내용을 저장하는 변수 생성
    var originalMemoContent: String?

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // 토큰 설정하기
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?
    
    // 옵져버 해제하기
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        // memoTextView에 있는 text를 newMemo로 저장!
        guard let memo = memoTextView.text, memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
        
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else {
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        // 데이터 베이스 저장하기!
//        DataManager.shared.addNewMemo(memo)
        
        // NotificationCenter Post 설정하기
        
        // 새 메모 창을 닫기
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }
        
        memoTextView.delegate = self
        
        // 키보드가 생길 때 여백이 생기는 코드!
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else {return}
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                // height에 키보드 높이를 저장한다.
                let height = frame.cgRectValue.height
                
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset
                
                // 스크롤도 inset을 주자
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
        })
        
        // keyboard가 없어질 때 여백 없애기
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else {return}
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 열리자마자 바로 편집 가능하게 커서가 생김
        memoTextView.becomeFirstResponder()
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //FirstResponder 해제하기
        memoTextView.resignFirstResponder()
        navigationController?.presentationController?.delegate = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeViewController: UITextViewDelegate {
    
    // textView에서 text가 변경될 때마다 호출이 된다.
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            // 원본과 편집된 것이 같은 지 다른지를 판단하여 편집이 된것인지 체크를 할 수 있다.
            // 만약 다르다면(편집이 된 것이라면) isModalInPresentation -> true -> sheet를 내리는 것도 불가능하다.
            isModalInPresentation = original != edited
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    
    // 만약 isModalInPresentation가 true라면 아래의 함수가 호출이 된다.
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    
        // 경고 창 띄우기
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        // 확인 액션 만들기
        // 경고창에서 확인버튼을 누르면 클로져가 실행이 된다. -> save가 된다.
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in
            self?.save(action)
        }
        alert.addAction(okAction)
        
        // 취소 액션 만들기
        // 경고창에서 취소버튼을 누르면 클로져가 실행이 된다.
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in
            self?.close(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
