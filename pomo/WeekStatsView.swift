//
//  WeekStatsView.swift
//  pomo
//
//  Created by Egon Manya on 04.02.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//
import Macaw
import Foundation

extension Date {
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }
}

open class WeekStatsView: MacawView {
    
    open var completionCallback: (() -> ()) = { }
    
    private var backgroundGroup = Group()
    private var mainGroup = Group()
    private var captionsGroup = Group()
    private var maxLimit = 1
    private var barAnimations = [Animation]()
    private var barsValues = [0, 0, 0, 0, 0, 0, 0]
    private let barsCaptions = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let barsCount = 7
    private let barsSpacing = 30
    private let barWidth = 15
    private let barHeight = 100
    
    private let emptyBarColor = Color(val: 0x1c1c1c)
    private let gradientColor = LinearGradient(degree: 90, from: Color(val: 0x00ff00), to: Color(val: 0x00adff))
    
    public func setBarsValues(values: [Day]) {
        for day in values {
            if abs((day.date?.compare(with: Date(), only: .day))!) <= 7 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat  = "EE" // "EE" to get short style
                let idx = barsCaptions.firstIndex(of: dateFormatter.string(from: day.date!).uppercased())!
                barsValues[idx] = Int(day.workedHoursInSeconds)
            }
        }
        maxLimit = lrint(values.max{ $0.workedHoursInSeconds < $1.workedHoursInSeconds }!.workedHoursInSeconds) + 60*60
    }
    
    private func createScene() {
        let viewCenterX = Double(self.frame.width / 2)
        
        let barsWidth = Double((barWidth * barsCount) + (barsSpacing * (barsCount - 1)))
        let barsCenterX = viewCenterX - barsWidth / 2

        backgroundGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: 0,
                        w: Double(barWidth),
                        h: Double(barHeight)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: emptyBarColor
            )
            backgroundGroup.contents.append(barShape)
        }
        
        mainGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: Double(barHeight),
                        w: Double(barWidth),
                        h: Double(0)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: gradientColor
            )
            mainGroup.contents.append([barShape].group())
        }
        
        backgroundGroup.place = Transform.move(dx: barsCenterX, dy: 15)
        mainGroup.place = Transform.move(dx: barsCenterX, dy: 15)
        
        captionsGroup = Group()
        captionsGroup.place = Transform.move(
            dx: barsCenterX,
            dy: 25 + Double(barHeight)
        )
        for barIndex in 0...barsCount - 1 {
            let text = Text(
                text: barsCaptions[barIndex],
                font: Font(name: "Gotham", size: 14),
                fill: Color(val: 0xFFFFFF)
            )
            text.align = .mid
            text.place = .move(
                dx: Double((barIndex * (barWidth + barsSpacing)) + barWidth / 2),
                dy: 0
            )
            captionsGroup.contents.append(text)
        }
        
        self.node = [backgroundGroup, mainGroup, captionsGroup].group()
        self.backgroundColor = UIColor.black
        
    }
    
    private func createAnimations() {
        barAnimations.removeAll()
        for (index, node) in mainGroup.contents.enumerated() {
            if let group = node as? Group {
                let percent = (Double(barsValues[index])/Double(maxLimit)) * 100
                let heightValue = self.barHeight / 100 * lrint(percent)
                let animation = group.contentsVar.animation({ t in
                    let value = Double(heightValue) / 100 * (t * 100)
                    let barShape = Shape(
                        form: RoundRect(
                            rect: Rect(
                                x: Double(index * (self.barWidth + self.barsSpacing)),
                                y: Double(self.barHeight) - Double(value),
                                w: Double(self.barWidth),
                                h: Double(value)
                            ),
                            rx: 5,
                            ry: 5
                        ),
                        fill: self.gradientColor
                    )
                    return [barShape]
                }, during: 0.2, delay: 0).easing(Easing.easeInOut)
                barAnimations.append(animation)
            }
        }
    }
    
    open func play() {
        createScene()
        createAnimations()
        barAnimations.sequence().onComplete {
            self.completionCallback()
        }.play()
    }
    
}
