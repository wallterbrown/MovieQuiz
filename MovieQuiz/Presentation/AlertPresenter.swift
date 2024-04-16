//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 08.04.2024.
//

import UIKit

class AlertPresenter {
    static func presentAlert(from viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}

