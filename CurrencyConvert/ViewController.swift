//
//  ViewController.swift
//  CurrencyConvert
//
//  Created by Marco on 25/04/2019.
//  Copyright © 2019 vikings. All rights reserved.
//

import Eureka

class ViewController: FormViewController {
    
    let defaults = UserDefaults.standard
    var transCurr:String = "USD"
    var crdhldBillCurr:String = "EUR"
    var selectedDate:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transCurr = defaults.string(forKey: "transCurr") ?? "USD"
        crdhldBillCurr = defaults.string(forKey: "crdhldBillCurr") ?? "EUR"
        selectedDate = defaults.string(forKey: "selectedDate") ?? "EUR"

        buildForm()
        
    } //end viewController
    
    @IBAction func openSettings(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    
    private func buildForm(){
        
        form +++ Section()
            
            <<< DecimalRow() {
                $0.title = "Transaction amount"
                $0.tag = "amount"
                let formatter = CurrencyFormatter()
                formatter.locale = .init(identifier: "en_US")
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }
            
        +++ Section()
            
            <<< DecimalRow() {
                $0.title = "Bank fee"
                $0.value = 3
                $0.tag = "fee"
                
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "%"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
                }
            }
            
            <<< DecimalRow() {
                $0.title = "Tip"
                $0.value = 0.0
                $0.tag = "tip"
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "%"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
                    }
            }
            
            <<< DecimalRow() {
                $0.title = "Tax"
                $0.value = 0.0
                $0.tag = "tax"
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "%"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
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
                    let tipForm: DecimalRow? = self?.form.rowBy(tag: "tip")
                    let taxForm: DecimalRow? = self?.form.rowBy(tag: "tax")

                    if amountForm?.value==nil || feeForm?.value==nil {
                        self!.showAlert(title: "Error", message: "Fill the missing fields")
                    } else {
                        
                        var amount = Double(amountForm!.value!)
                        let fee = Double(feeForm!.value!)
                        let tip = Double(tipForm!.value!)
                        let tax = Double(taxForm!.value!)
                        
                        DispatchQueue.main.async {
                            self!.transCurr = self!.defaults.string(forKey: "transCurr") ?? "USD"
                            self!.crdhldBillCurr = self!.defaults.string(forKey: "crdhldBillCurr") ?? "EUR"
                            self!.selectedDate = self!.defaults.string(forKey: "selectedDate") ?? "EUR"
                            
                            API().getConversionRates(from: self!.transCurr, to: self!.crdhldBillCurr, date: self!.selectedDate, completionHandler: {
                                (conversion_rate) in
                                
                                //add fee to conversion rate
                                let conversion_rate_with_fee = conversion_rate + (fee/100.0)
                                
                                let original_tip = (amount*tip)/100.0
                                let original_tax = (amount*tax)/100.0
                                
                                if tip != 0.0 {
                                    amount += original_tip
                                }
                                if tax != 0.0 {
                                    amount += original_tax
                                }
                                let amount_to_pay = (conversion_rate_with_fee * amount)
                                let amount_to_pay_no_tax = (conversion_rate * amount)
                                let difference = amount_to_pay_no_tax - amount_to_pay
                                
                                let amountToPay_row = self!.form.rowBy(tag: "amount_to_pay") as! DecimalRow
                                amountToPay_row.value = self!.roundToPlaces(value: amount_to_pay, places: 2)
                                amountToPay_row.reload()
                                
//                                let conversion_rate_row = self!.form.rowBy(tag: "conversion_rate") as! DecimalRow
//                                conversion_rate_row.value = conversion_rate_with_fee
//                                conversion_rate_row.reload()

                                let amountToPay_row_no_tax = self!.form.rowBy(tag: "amount_to_pay_no_tax") as! DecimalRow
                                amountToPay_row_no_tax.value = self!.roundToPlaces(value: amount_to_pay_no_tax, places: 2)
                                amountToPay_row_no_tax.reload()
                                
//                                let conversion_rate_row_no_tax = self!.form.rowBy(tag: "conversion_rate_no_tax") as! DecimalRow
//                                conversion_rate_row_no_tax.value = conversion_rate
//                                conversion_rate_row_no_tax.reload()
                                
                                let difference_row = self!.form.rowBy(tag: "difference") as! DecimalRow
                                difference_row.value = self!.roundToPlaces(value: difference, places: 2)
                                difference_row.reload()
                                
                                let original_amount_row = self!.form.rowBy(tag: "original_amount") as! DecimalRow
                                original_amount_row.value = self!.roundToPlaces(value: amount, places: 2)
                                original_amount_row.reload()

                                let original_tip_row = self!.form.rowBy(tag: "original_tip") as! DecimalRow
                                original_tip_row.value = self!.roundToPlaces(value: original_tip, places: 2)
                                original_tip_row.reload()
                                
                                let original_tax_row = self!.form.rowBy(tag: "original_tax") as! DecimalRow
                                original_tax_row.value = self!.roundToPlaces(value: original_tax, places: 2)
                                original_tax_row.reload()
                                
                                
                                if let section = self!.form.sectionBy(tag: "button_section") {
                                    if let date = UserDefaults.standard.object(forKey: "date") as? Date {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm dd MMM"
                                        var last_updated = ""
                                        if formatter.string(from: date) == formatter.string(from: Date()) {
                                            last_updated = "now"
                                        } else {
                                            last_updated = formatter.string(from: date)
                                        }
                                        section.footer = HeaderFooterView(title: "Last updated: \(last_updated) ")
                                        section.reload()
                                    }
                                }
                                
                                if let section = self!.form.sectionBy(tag: "section_with_fee") {
                                    section.footer = HeaderFooterView(title: "Conversion rate: \(self!.roundToPlaces(value: conversion_rate_with_fee, places: 3)) ")
                                    section.reload()
                                }
                                
                                if let section = self!.form.sectionBy(tag: "section_without_fee") {
                                    section.footer = HeaderFooterView(title: "Conversion rate: \(self!.roundToPlaces(value: conversion_rate, places: 3)) ")
                                    section.reload()
                                }
                                
                                
                            })
                            
                        }
                        
                    }
            }
            
            
            +++ Section() {section in
                section.tag = "section_with_fee"
            }
            
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
            
//                <<< DecimalRow() {
//                    $0.title = "Conversion Rate with fee"
//                    $0.tag = "conversion_rate"
//                    $0.disabled = true
//                }
        
            +++ Section() {section in
                section.tag = "section_without_fee"
            }
            
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
            
//                <<< DecimalRow() {
//                    $0.title = "Conversion Rate without fee"
//                    $0.tag = "conversion_rate_no_tax"
//                    $0.disabled = true
//                }
        
                <<< DecimalRow(){
                    $0.title = "Difference"
                    $0.tag = "difference"
                    $0.disabled = true
                    let formatter = CurrencyFormatter()
                    formatter.locale = .init(identifier: "it_IT")
                    formatter.numberStyle = .currency
                    $0.formatter = formatter
                }
        
            +++ Section() {section in
                section.tag = "original_section"
            }
            
            <<< DecimalRow() {
                $0.title = "Original amount"
                $0.tag = "original_amount"
                $0.disabled = true
                let formatter = CurrencyFormatter()
                formatter.locale = .init(identifier: "en_US")
                formatter.numberStyle = .currency
                $0.formatter = formatter
        }
        
            <<< DecimalRow() {
                $0.title = "Tip"
                $0.value = 0.0
                $0.tag = "original_tip"
                $0.disabled = true
                let formatter = CurrencyFormatter()
                formatter.locale = .init(identifier: "en_US")
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
            
            <<< DecimalRow() {
                $0.title = "Tax"
                $0.value = 0.0
                $0.tag = "original_tax"
                $0.disabled = true
                let formatter = CurrencyFormatter()
                formatter.locale = .init(identifier: "en_US")
                formatter.numberStyle = .currency
                $0.formatter = formatter
            }
        
        

    }

    public func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }
    
    public func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
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



