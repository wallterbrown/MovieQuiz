//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 04.04.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    
    func requestNextQuestion()
    func setup(delegate: QuestionFactoryDelegate)
}

