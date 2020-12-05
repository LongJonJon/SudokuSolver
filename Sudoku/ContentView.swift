//
//  ContentView.swift
//  Sudoku
//
//  Created by Jon Kido on 2/6/20.
//  Copyright © 2020 Jon Kido. All rights reserved.
//

import SwiftUI
import Combine

class Cell {
    var title = 0
    var original = false
    var currentColor:[Color] = [Color.white, Color(red: 0.7, green: 0.85, blue: 1), Color(red: 0.95, green: 0.95, blue: 0.95), Color(red: 0.7, green: 0.9, blue: 1)]
    var colorIndex:Int = 0;
    
    // functionality
    init(num:Int = 0) {
        title = num
    }
    
    func GetNumber() -> Int {
        return title
    }
    
    func Original(bool:Bool){
        original = bool
    }
    
    func GetTitle() -> String {
        if(title != 0){
            return String(title)
        }
        return "   "
    }
    
    func SetNumber(num: Int) {
        title = num
    }
    
    func Whip(){
        if !original {
            title = 0
        }
    }
    
    // aesthetics
    func ColorIn(color:String){
        switch color {
        case "select":
            colorIndex = 1
        case "borSelect":
            colorIndex = 2
        case "sameNum":
            colorIndex = 3
        default:
            colorIndex = 0
        }
    }
    
    func GetColor() -> Color {
        return currentColor[colorIndex]
    }
    
    func ChangeTitle(num:Int){
        if (!original){
            title = num
        }
    }
    
    func GetTextColor() -> Color {
        if(original){
            return Color.black
        }
        return Color.blue
    }
}

struct ContentView: View {
    @State var update:Bool = false
    @State var selectedNum = 0
    @State var set: Bool = true
    @State var index: [Int] = [-1,-1]
    var board: [[Cell]] = [
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()],
        [Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell(),Cell()]
    ]
    
    func GetAvailable(x:Int, y:Int) -> [Int]{
        var availableNum = [1,2,3,4,5,6,7,8,9]
        for xi in 0...8 {
            if (availableNum.count == 0){
                return availableNum
            }
            for n in 0...(availableNum.count-1) {
                if availableNum[n] == self.board[xi][y].GetNumber(){
                    availableNum.remove(at: n)
                    break
                }
            }
        }
        
        for yi in 0...8 {
            if (availableNum.count == 0){
                return availableNum
            }
            for n in 0...(availableNum.count-1) {
                if availableNum[n] == self.board[x][yi].GetNumber(){
                    availableNum.remove(at: n)
                    break
                }
            }
        }
        
        for xii in 0...2 {
            for yii in 0...2 {
                if (availableNum.count == 0){
                    return availableNum
                }
                for n in 0...(availableNum.count-1) {
                    if availableNum[n]  == self.board[xii+x/3*3][yii+y/3*3].GetNumber(){
                        availableNum.remove(at: n)
                        break
                    }
                }
            }
        }
        return availableNum
    }
    
    func CreateRandomBoard() -> Int {
        for x in 0...8 {
            for y in 0...8 {
                let nums:[Int] = GetAvailable(x:x, y:y)
                if nums.count > 0 {
                    self.board[x][y].SetNumber(num: nums[Int.random(in: 0...(nums.count-1))])
                }
                
                for dy in 0...8 {
                    let nums:[Int] = GetAvailable(x:x, y:dy)
                    if nums.count == 1 {
                        self.board[x][dy].SetNumber(num: nums[0])
                    }
                }
                if self.board[x][y].GetNumber() == 0 {
                    BoardReset()
                    return -1
                }
            }
        }
        return 0
    }
    
    func BoardReset(type:Int = -1){
        for x in board {
            for y in x {
                switch type {
                case 0:
                    y.Whip()
                default:
                    y.SetNumber(num: 0)
                    y.Original(bool: false)
                }
            }
        }
    }
    
    func StartSudoku(){
        self.update.toggle()
        var incomplete = true
        repeat {
            if CreateRandomBoard() == 0 {
                incomplete = false
            }
        } while incomplete
        
        for _ in 0...40 {
            self.board[Int.random(in: 0...8)][Int.random(in: 0...8)].Original(bool: true)
        }
        
        BoardReset(type: 0)
    }
    
    func ColorIn(){
        for x in 0...8 {
            for y in 0...8 {
                if index[0] == x && index[1] == y {
                    self.board[x][y].ColorIn(color: "select")
                } else if selectedNum != 0 && selectedNum == self.board[x][y].GetNumber() {
                    self.board[x][y].ColorIn(color: "sameNum")
                } else if (index[0] == x || index[1] == y) || ((x / 3) == (index[0] / 3) && (y / 3) == (index[1] / 3)) {
                    self.board[x][y].ColorIn(color: "borSelect")
                } else {
                    self.board[x][y].ColorIn(color: "deselect")
                }
            }
        }
        self.update.toggle()
    }
    
    func GetIndex(x:Int = 0, y:Int = 0, r:Bool = false){
        if !r {
            self.index = [x,y]
        }
        
        if self.index[0] != -1 {
            self.selectedNum = self.board[self.index[0]][self.index[1]].GetNumber()
            ColorIn()
        }
    }
    
    
    var body: some View {
        VStack {
            Text("Sudoku")
                .onAppear { self.StartSudoku() }
            // Visual Board Setup
            ZStack{
                Text(String(update)+", "+String(index[0])+", "+String(index[1]))
                Rectangle().fill(Color(red: 0.8, green: 0.8, blue:0.8)).frame(width: 390, height: 375)
                VStack{
                    HStack{
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                    }.padding(.top, 0.0)
                    HStack{
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                    }.padding(.top, -2.0)
                    HStack{
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                        Rectangle().fill(Color(red: 0.9, green: 0.9, blue:0.9)).frame(width: 121, height: 117)
                    }.padding(.top, -2.0)
                }
                
                // Index Button Placement
                VStack{
                    HStack{
                        ZStack{
                            Text("1 2 3\n4 5 6\n7 8 9").font(.system(size: 9))
                            Button(String(self.board[0][0].GetTitle())){
                                self.GetIndex(x:0, y:0)
                            }.accentColor(self.board[0][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][1].GetTitle())){
                                self.GetIndex(x:0, y:1)
                            }.accentColor(self.board[0][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][2].GetTitle())){
                                self.GetIndex(x:0, y:2)
                            }.accentColor(self.board[0][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][3].GetTitle())){
                                self.GetIndex(x:0, y:3)
                            }.accentColor(self.board[0][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][4].GetTitle())){
                                self.GetIndex(x:0, y:4)
                            }.accentColor(self.board[0][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][5].GetTitle())){
                                self.GetIndex(x:0, y:5)
                            }.accentColor(self.board[0][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][6].GetTitle())){
                                self.GetIndex(x:0, y:6)
                            }.accentColor(self.board[0][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][7].GetTitle())){
                                self.GetIndex(x:0, y:7)
                            }.accentColor(self.board[0][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[0][8].GetTitle())){
                                self.GetIndex(x:0, y:8)
                            }.accentColor(self.board[0][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[0][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[1][0].GetTitle())){
                                self.GetIndex(x:1, y:0)
                            }.accentColor(self.board[1][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][1].GetTitle())){
                                self.GetIndex(x:1, y:1)
                            }.accentColor(self.board[1][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][2].GetTitle())){
                                self.GetIndex(x:1, y:2)
                            }.accentColor(self.board[1][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][3].GetTitle())){
                                self.GetIndex(x:1, y:3)
                            }.accentColor(self.board[1][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][4].GetTitle())){
                                self.GetIndex(x:1, y:4)
                            }.accentColor(self.board[1][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][5].GetTitle())){
                                self.GetIndex(x:1, y:5)
                            }.accentColor(self.board[1][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][6].GetTitle())){
                                self.GetIndex(x:1, y:6)
                            }.accentColor(self.board[1][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][7].GetTitle())){
                                self.GetIndex(x:1, y:7)
                            }.accentColor(self.board[1][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[1][8].GetTitle())){
                                self.GetIndex(x:1, y:8)
                            }.accentColor(self.board[1][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[1][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[2][0].GetTitle())){
                                self.GetIndex(x:2, y:0)
                            }.accentColor(self.board[2][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][1].GetTitle())){
                                self.GetIndex(x:2, y:1)
                            }.accentColor(self.board[2][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][2].GetTitle())){
                                self.GetIndex(x:2, y:2)
                            }.accentColor(self.board[2][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][3].GetTitle())){
                                self.GetIndex(x:2, y:3)
                            }.accentColor(self.board[2][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][4].GetTitle())){
                                self.GetIndex(x:2, y:4)
                            }.accentColor(self.board[2][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][5].GetTitle())){
                                self.GetIndex(x:2, y:5)
                            }.accentColor(self.board[2][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][6].GetTitle())){
                                self.GetIndex(x:2, y:6)
                            }.accentColor(self.board[2][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][7].GetTitle())){
                                self.GetIndex(x:2, y:7)
                            }.accentColor(self.board[2][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[2][8].GetTitle())){
                                self.GetIndex(x:2, y:8)
                            }.accentColor(self.board[2][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[2][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[3][0].GetTitle())){
                                self.GetIndex(x:3, y:0)
                            }.accentColor(self.board[3][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][1].GetTitle())){
                                self.GetIndex(x:3, y:1)
                            }.accentColor(self.board[3][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][2].GetTitle())){
                                self.GetIndex(x:3, y:2)
                            }.accentColor(self.board[3][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][3].GetTitle())){
                                self.GetIndex(x:3, y:3)
                            }.accentColor(self.board[3][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][4].GetTitle())){
                                self.GetIndex(x:3, y:4)
                            }.accentColor(self.board[3][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][5].GetTitle())){
                                self.GetIndex(x:3, y:5)
                            }.accentColor(self.board[3][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][6].GetTitle())){
                                self.GetIndex(x:3, y:6)
                            }.accentColor(self.board[3][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][7].GetTitle())){
                                self.GetIndex(x:3, y:7)
                            }.accentColor(self.board[3][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[3][8].GetTitle())){
                                self.GetIndex(x:3, y:8)
                            }.accentColor(self.board[3][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[3][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[4][0].GetTitle())){
                                self.GetIndex(x:4, y:0)
                            }.accentColor(self.board[4][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][1].GetTitle())){
                                self.GetIndex(x:4, y:1)
                            }.accentColor(self.board[4][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][2].GetTitle())){
                                self.GetIndex(x:4, y:2)
                            }.accentColor(self.board[4][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][3].GetTitle())){
                                self.GetIndex(x:4, y:3)
                            }.accentColor(self.board[4][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][4].GetTitle())){
                                self.GetIndex(x:4, y:4)
                            }.accentColor(self.board[4][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][5].GetTitle())){
                                self.GetIndex(x:4, y:5)
                            }.accentColor(self.board[4][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][6].GetTitle())){
                                self.GetIndex(x:4, y:6)
                            }.accentColor(self.board[4][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][7].GetTitle())){
                                self.GetIndex(x:4, y:7)
                            }.accentColor(self.board[4][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[4][8].GetTitle())){
                                self.GetIndex(x:4, y:8)
                            }.accentColor(self.board[4][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[4][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[5][0].GetTitle())){
                                self.GetIndex(x:5, y:0)
                            }.accentColor(self.board[5][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][1].GetTitle())){
                                self.GetIndex(x:5, y:1)
                            }.accentColor(self.board[5][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][2].GetTitle())){
                                self.GetIndex(x:5, y:2)
                            }.accentColor(self.board[5][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][3].GetTitle())){
                                self.GetIndex(x:5, y:3)
                            }.accentColor(self.board[5][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][4].GetTitle())){
                                self.GetIndex(x:5, y:4)
                            }.accentColor(self.board[5][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][5].GetTitle())){
                                self.GetIndex(x:5, y:5)
                            }.accentColor(self.board[5][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][6].GetTitle())){
                                self.GetIndex(x:5, y:6)
                            }.accentColor(self.board[5][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][7].GetTitle())){
                                self.GetIndex(x:5, y:7)
                            }.accentColor(self.board[5][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[5][8].GetTitle())){
                                self.GetIndex(x:5, y:8)
                            }.accentColor(self.board[5][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[5][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[6][0].GetTitle())){
                                self.GetIndex(x:6, y:0)
                            }.accentColor(self.board[6][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][1].GetTitle())){
                                self.GetIndex(x:6, y:1)
                            }.accentColor(self.board[6][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][2].GetTitle())){
                                self.GetIndex(x:6, y:2)
                            }.accentColor(self.board[6][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][3].GetTitle())){
                                self.GetIndex(x:6, y:3)
                            }.accentColor(self.board[6][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][4].GetTitle())){
                                self.GetIndex(x:6, y:4)
                            }.accentColor(self.board[6][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][5].GetTitle())){
                                self.GetIndex(x:6, y:5)
                            }.accentColor(self.board[6][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][6].GetTitle())){
                                self.GetIndex(x:6, y:6)
                            }.accentColor(self.board[6][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][7].GetTitle())){
                                self.GetIndex(x:6, y:7)
                            }.accentColor(self.board[6][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[6][8].GetTitle())){
                                self.GetIndex(x:6, y:8)
                            }.accentColor(self.board[6][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[6][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[7][0].GetTitle())){
                                self.GetIndex(x:7, y:0)
                            }.accentColor(self.board[7][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][1].GetTitle())){
                                self.GetIndex(x:7, y:1)
                            }.accentColor(self.board[7][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][2].GetTitle())){
                                self.GetIndex(x:7, y:2)
                            }.accentColor(self.board[7][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][3].GetTitle())){
                                self.GetIndex(x:7, y:3)
                            }.accentColor(self.board[7][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][4].GetTitle())){
                                self.GetIndex(x:7, y:4)
                            }.accentColor(self.board[7][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][5].GetTitle())){
                                self.GetIndex(x:7, y:5)
                            }.accentColor(self.board[7][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][6].GetTitle())){
                                self.GetIndex(x:7, y:6)
                            }.accentColor(self.board[7][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][7].GetTitle())){
                                self.GetIndex(x:7, y:7)
                            }.accentColor(self.board[7][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[7][8].GetTitle())){
                                self.GetIndex(x:7, y:8)
                            }.accentColor(self.board[7][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[7][8].GetColor())
                    }.padding(3)
                    HStack{
                        ZStack{
                            
                            Button(String(self.board[8][0].GetTitle())){
                                self.GetIndex(x:8, y:0)
                            }.accentColor(self.board[8][0].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][0].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][1].GetTitle())){
                                self.GetIndex(x:8, y:1)
                            }.accentColor(self.board[8][1].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][1].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][2].GetTitle())){
                                self.GetIndex(x:8, y:2)
                            }.accentColor(self.board[8][2].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][2].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][3].GetTitle())){
                                self.GetIndex(x:8, y:3)
                            }.accentColor(self.board[8][3].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][3].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][4].GetTitle())){
                                self.GetIndex(x:8, y:4)
                            }.accentColor(self.board[8][4].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][4].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][5].GetTitle())){
                                self.GetIndex(x:8, y:5)
                            }.accentColor(self.board[8][5].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][5].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][6].GetTitle())){
                                self.GetIndex(x:8, y:6)
                            }.accentColor(self.board[8][6].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][6].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][7].GetTitle())){
                                self.GetIndex(x:8, y:7)
                            }.accentColor(self.board[8][7].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][7].GetColor())
                        ZStack{
                            
                            Button(String(self.board[8][8].GetTitle())){
                                self.GetIndex(x:8, y:8)
                            }.accentColor(self.board[8][8].GetTextColor())
                        }.frame(width: 35, height: 35).background(self.board[8][8].GetColor())
                    }.padding(3)
                }
            }
            HStack{
                Rectangle().frame(width: 1, height: 0)
                Button("New Puzzle"){
                    self.BoardReset()
                    self.StartSudoku()
                    self.GetIndex(r: true)
                }.frame(width: 110, height: 30).background(Color.red)
                Rectangle().frame(width: 160, height: 0)
                Toggle(isOn: $set){
                    Text("Set:")
                }.padding(.trailing, 10.0).frame(width: 99)
            }
            
            HStack {
                Button(" 1 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 1)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 2 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 2)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 3 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 3)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 4 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 4)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 5 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 5)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 6 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 6)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 7 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 7)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 8 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 8)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
                
                Button(" 9 ") {
                    self.board[self.index[0]][self.index[1]].ChangeTitle(num: 9)
                    self.GetIndex(r: true)
                    self.update.toggle()
                }.padding(10).background(Color.blue).accentColor(.white).cornerRadius(10)
            }.padding(5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
