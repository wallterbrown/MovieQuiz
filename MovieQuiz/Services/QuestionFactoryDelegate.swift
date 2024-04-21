//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 04.04.2024.
//

import Foundation

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
