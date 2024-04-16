//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 08.04.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
