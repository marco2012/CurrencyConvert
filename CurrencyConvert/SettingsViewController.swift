//
//  SettingsViewController.swift
//  CurrencyConvert
//
//  Created by Marco on 30/04/2019.
//  Copyright © 2019 vikings. All rights reserved.
//

import Eureka

class SettingsViewController: FormViewController {

    let defaults = UserDefaults.standard
    var transCurr:String = "USD"
    var crdhldBillCurr:String = "EUR"
    var selectedDate:String = ""
    let currencies = ["EUR", "USD", "JPY", "BGN", "CZK", "DKK", "GBP", "HUF", "PLN", "RON", "SEK", "CHF", "ISK", "NOK", "HRK", "RUB", "TRY", "AUD", "BRL", "CAD", "CNY", "HKD", "IDR", "ILS", "INR", "KRW", "MXN", "MYR", "NZD", "PHP", "SGD", "THB", "ZAR"].sorted()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transCurr = self.defaults.string(forKey: "transCurr") ?? "USD"
        self.crdhldBillCurr = self.defaults.string(forKey: "crdhldBillCurr") ?? "EUR"
        self.selectedDate = self.defaults.string(forKey: "selectedDate") ?? ""
        selectedDate = formatDate(date: Date())
        
        buildForm()

    } //end SettingsViewController
    
    
    @IBAction func closeSettings(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func formatDate(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func buildForm(){
        
        form +++ Section("Transaction Details")
            
            <<< PushRow<String>() {
                $0.title = "Transaction Currency"
                $0.tag = "transCurr"
                $0.options = currencies
                $0.value = "USD"
                $0.selectorTitle = "Transaction Currency"
                }.onPresent { from, to in
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                    to.selectableRowCellUpdate = { cell, row in
                        cell.textLabel?.text = row.selectableValue!
                    }
                }.onChange { [unowned self] row in
                    if (row.value != nil){
                        self.transCurr = row.value!
                        self.defaults.set(self.transCurr, forKey: "transCurr")
                    }
            }
            
            <<< DateRow(){
                $0.title = "Transaction date"
                $0.value = Date()
                $0.tag = "date"
                }.cellUpdate { (cell, row) in
                    cell.datePicker.maximumDate = Date()
                }.onChange({ (row) in
                    self.selectedDate = self.formatDate(date: row.value!)   //updating the value on change
                    self.defaults.set(self.selectedDate, forKey: "selectedDate")
                })
            
            
            +++ Section("Your Card Details")
            
//            <<< DecimalRow() {
//                $0.title = "Bank fee (%)"
//                $0.value = 3
//                $0.tag = "fee"
//            }
            
            <<< PushRow<String>() {
                $0.title = "Cardholder billing Currency"
                $0.tag = "crdhldBillCurr"
                $0.options = currencies
                $0.value = "EUR"
                $0.selectorTitle = "Cardholder billing Currency"
                }.onPresent { from, to in
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                    to.selectableRowCellUpdate = { cell, row in
                        cell.textLabel?.text = row.selectableValue!
                    }
                }.onChange { [unowned self] row in
                    if (row.value != nil){
                        self.crdhldBillCurr = row.value!
                        self.defaults.set(self.crdhldBillCurr, forKey: "crdhldBillCurr")
                    }
            }
        
        
    }
    

}
