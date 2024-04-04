//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 04.04.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
    
}
