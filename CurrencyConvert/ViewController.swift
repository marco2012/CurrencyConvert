//
//  ViewController.swift
//  CurrencyConvert
//
//  Created by Marco on 25/04/2019.
//  Copyright © 2019 vikings. All rights reserved.
//

import Eureka
import Alamofire
import SwiftyJSON

class ViewController: FormViewController {
    
    var transCurr:String = "USD"
    var crdhldBillCurr:String = "EUR"
    var selectedDate:String = ""
    let currencies = ["USD", "JPY", "BGN", "CZK", "DKK", "GBP", "HUF", "PLN", "RON", "SEK", "CHF", "ISK", "NOK", "HRK", "RUB", "TRY", "AUD", "BRL", "CAD", "CNY", "HKD", "IDR", "ILS", "INR", "KRW", "MXN", "MYR", "NZD", "PHP", "SGD", "THB", "ZAR"].sorted()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDate = formatDate(date: Date())
        
        buildForm()
        
    } //end viewController
    
    func buildForm(){
        
        form +++ Section("Transaction Details")
            
            <<< DecimalRow() {
                $0.title = "Transaction amount"
                $0.tag = "amount"
                let formatter = CurrencyFormatter()
                formatter.locale = .init(identifier: "en_US")
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            
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
                })
            
            
            +++ Section("Your Card Details")
            
            <<< DecimalRow() {
                $0.title = "Bank fee (%)"
                $0.value = 3
                $0.tag = "fee"
            }
            
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
                    }
            }
            
            +++ Section() {section in
                section.tag = "button_section"
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Calculate"
                }
                .onCellSelection { [weak self] (cell, row) in
                    let amountForm: DecimalRow? = self?.form.rowBy(tag: "amount")
                    let feeForm: DecimalRow? = self?.form.rowBy(tag: "fee")
                    if amountForm?.value==nil || feeForm?.value==nil {
                        self!.showAlert(title: "Error", message: "Fill the missing fields")
                    } else {
                        
                        let amount = Double(amountForm!.value!)
                        let fee = Double(feeForm!.value!)
                        
                        API().getConversionRates(from: self!.transCurr, to: self!.crdhldBillCurr, date: self!.selectedDate, completionHandler: {
                            (conversion_rate) in
                            
                            //add fee to conversion rate
                            let conversion_rate_with_fee = conversion_rate + (fee/100.0)
                            let amount_to_pay = (conversion_rate_with_fee*amount)
                            let amount_to_pay_no_tax = (conversion_rate*amount)
                            
                            let amountToPay_row = self!.form.rowBy(tag: "amount_to_pay") as! DecimalRow
                            amountToPay_row.value = self!.roundToPlaces(value: amount_to_pay, places: 2)
                            amountToPay_row.reload()
                            
                            let conversion_rate_row = self!.form.rowBy(tag: "conversion_rate") as! DecimalRow
                            conversion_rate_row.value = conversion_rate_with_fee
                            conversion_rate_row.reload()
                            
                            let amountToPay_row_no_tax = self!.form.rowBy(tag: "amount_to_pay_no_tax") as! DecimalRow
                            amountToPay_row_no_tax.value = self!.roundToPlaces(value: amount_to_pay_no_tax, places: 2)
                            amountToPay_row_no_tax.reload()
                            
                            let conversion_rate_row_no_tax = self!.form.rowBy(tag: "conversion_rate_no_tax") as! DecimalRow
                            conversion_rate_row_no_tax.value = conversion_rate
                            conversion_rate_row_no_tax.reload()
                            
                            if let section = self!.form.sectionBy(tag: "button_section") {
                                if let date = UserDefaults.standard.object(forKey: "date") as? Date {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm dd MMM"
                                    section.footer = HeaderFooterView(title: "Last updated: \(formatter.string(from: date)) ")
                                    section.reload()
                                }
                            }
                            
                        })
                        
                    }
            }
            
            
            +++ Section(header: "Result", footer: "The amount to pay includes taxes ")
            
                <<< DecimalRow(){
                    $0.useFormatterDuringInput = true
                    $0.title = "Amount to pay with fee"
                    $0.tag = "amount_to_pay"
                    $0.disabled = true
                    let formatter = CurrencyFormatter()
                    formatter.locale = .init(identifier: "it_IT")
                    formatter.numberStyle = .currency
                    $0.formatter = formatter
                }
            
                <<< DecimalRow() {
                    $0.title = "Conversion Rate with fee"
                    $0.tag = "conversion_rate"
                    $0.disabled = true
                }
        
            +++ Section(header: "Result without taxes", footer: "The amount to pay does not include taxes ")
            
                <<< DecimalRow(){
                    $0.useFormatterDuringInput = true
                    $0.title = "Amount to pay without fee"
                    $0.tag = "amount_to_pay_no_tax"
                    $0.disabled = true
                    let formatter = CurrencyFormatter()
                    formatter.locale = .init(identifier: "it_IT")
                    formatter.numberStyle = .currency
                    $0.formatter = formatter
                }
            
                <<< DecimalRow() {
                    $0.title = "Conversion Rate without fee"
                    $0.tag = "conversion_rate_no_tax"
                    $0.disabled = true
                }
        
    }

    func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }
    
    private func formatDate(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    class CurrencyFormatter : NumberFormatter, FormatterProtocol {
        override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
            guard obj != nil else { return }
            var str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if !string.isEmpty, numberStyle == .currency && !string.contains(currencySymbol) {
                // Check if the currency symbol is at the last index
                if let formattedNumber = self.string(from: 1), String(formattedNumber[formattedNumber.index(before: formattedNumber.endIndex)...]) == currencySymbol {
                    // This means the user has deleted the currency symbol. We cut the last number and then add the symbol automatically
                    str = String(str[..<str.index(before: str.endIndex)])
                    
                }
            }
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        }
        
        func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
            return textInput.position(from: position, offset:((newValue?.count ?? 0) - (oldValue?.count ?? 0))) ?? position
        }
    }

}



