//
//  CurrentRatesViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 8/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class CurrentRatesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var items = [CurrencyPair]()
    private let walletSvc = ServiceLocator.Application.walletService()
    private weak var interfaceCoordinator: InterfaceCoordinator?
    
    init(interfaceCoordinator: InterfaceCoordinator?) {
        self.interfaceCoordinator = interfaceCoordinator
        super.init(nibName: "CurrentRatesViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        let nib1 = UINib(nibName: "CurrentRateCell", bundle: nil)
        let nib2 = UINib(nibName: "CurrentRateNoteCell", bundle: nil)
        
        tableView.register(nib1, forCellReuseIdentifier: CurrentRateCell.identifier)
        tableView.register(nib2, forCellReuseIdentifier: CurrentRateNoteCell.identifier)
        
        loadCurrencies()
    }
    
    private func loadCurrencies() {
        interfaceCoordinator?.showActivityIndicator({ })
        
        let dg = DispatchGroup()
        
        // STEEM -> USD
        dg.enter()
        estimateOutputAmount(ict: Currency.steem, oct: Currency.bitusd, completion: { someSteemToBitusd in
            if let steemToBitusd = someSteemToBitusd {
                self.items.append(steemToBitusd)
                
                // SBD -> USD
                dg.enter()
                self.estimateOutputAmount(ict: Currency.sbd, oct: Currency.steem, completion: { someSbdToSteem in
                    if let sbdToSteem = someSbdToSteem, let sbdToBitusd = self.transform(cp1: sbdToSteem, cp2: steemToBitusd) {
                        self.items.append(sbdToBitusd)
                    }
                    dg.leave()
                })
                
                // ETH -> USD
                dg.enter()
                self.estimateOutputAmount(ict: Currency.eth, oct: Currency.steem, completion: { someEthToSteem in
                    if let ethToSteem = someEthToSteem, let ethToBitusd = self.transform(cp1: ethToSteem, cp2: steemToBitusd) {
                        self.items.append(ethToBitusd)
                    }
                    dg.leave()
                })
            }
            dg.leave()
        })
        
        // BTS -> USD
        dg.enter()
        estimateOutputAmount(ict: Currency.bts, oct: Currency.bitusd, completion: { someCurrentType in
            if let cp = someCurrentType {
                self.items.append(cp)
            }
            dg.leave()
        })
        
        
        // BTC -> USD
        dg.enter()
        estimateOutputAmount(ict: Currency.btc, oct: Currency.bitusd, completion: { someCurrentType in
            if let cp = someCurrentType {
                self.items.append(cp)
            }
            dg.leave()
        })
        
        
        dg.notify(queue: DispatchQueue.main) {
            self.items = self.items.sorted(by: { (cp1, cp2) -> Bool in
                let c1 = Currency.init(rawValue: cp1.inputCoinType) ?? Currency.steem
                let c2 = Currency.init(rawValue: cp2.inputCoinType) ?? Currency.steem
                
                return c1.sortIdx < c2.sortIdx
            })
            
            self.tableView.reloadData()
            self.interfaceCoordinator?.hideActivityIndicator({ })
        }
    }
    
    private func transform(cp1: CurrencyPair, cp2: CurrencyPair) -> CurrencyPair? {
        if cp1.outputCoinType != cp2.inputCoinType {
            return nil
        }
        
        let src = cp1.inputCoinType
        let srcAmnt = Double(cp1.outputAmount) ?? 0.0
        
        let dist = cp2.outputCoinType
        let distAmnt = Double(cp2.outputAmount) ?? 0.0
        
        return CurrencyPair(inputAmount: "1", inputCoinType: src, outputAmount: String(srcAmnt * distAmnt), outputCoinType: dist)
    }
    
    private func estimateOutputAmount(ict: Currency, oct: Currency, completion: @escaping (CurrencyPair?) -> ()) {
        self.walletSvc.estimateOutputAmount(ict: ict, oct: oct) { res in
            if case .success(let cp) = res {
                completion(cp)
            } else {
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Data for some currency is not available"))
                completion(nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension CurrentRatesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == items.count {
            return tableView.dequeueReusableCell(withIdentifier: CurrentRateNoteCell.identifier, for: indexPath) as! CurrentRateNoteCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrentRateCell.identifier, for: indexPath) as! CurrentRateCell
            let item = items[indexPath.row]
            
            cell.configure(cp: item)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51.0
    }
}
