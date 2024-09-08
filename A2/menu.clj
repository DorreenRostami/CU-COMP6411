(ns menu
    (:require db))


(defn get-2d [v i j]
    (get (get v i) j))

(defn main-loop [customers products sales]
    (print "\u001b[2J")
    (print "\u001b[H")
    (println "*** Sales Menu ***\n------------------")
    (println "1. Display Customer Table\n2. Display Product Table\n3. Display Sales Table\n4. Total Sales for Customer\n5. Total Count for Product\n6. Exit")
    (println "Enter an option:")
    (let [choice (read-line)]
    (case choice
    "1" (do (doseq [cust customers]
            (println "Customer" (get cust 0) ":" (get cust 1) "," (get cust 2) "," (get cust 3)))
        (println "Press Enter to go back to menu:")
        (read-line)
        (recur customers products sales)
        )
    "2" (do (doseq [p products]
            (println "Product" (get p 0) ":" (get p 1) "," (get p 2)))
        (println "Press Enter to go back to menu:")
        (read-line)
        (recur customers products sales)
        )
    "3" (do (doseq [s sales]
            (let [cust-id (- (Integer/parseInt (get s 1)) 1)
                prod-id (- (Integer/parseInt (get s 2)) 1)]
            (println "Sales" (get s 0) ":" (get-2d customers cust-id 1) "," (get-2d products prod-id 1) "," (get s 3))))
        (println "Press Enter to go back to menu:")
        (read-line)
        (recur customers products sales)
        )
    "4" (do
        (println "Enter customer name:")
        (let [name (read-line)
            cust-id (get (get (filterv (fn [x] (= name (get x 1))) customers) 0) 0)
            purchases (filterv (fn [x] (= cust-id (get x 1))) sales)]
            (if (= (count purchases) 0)
                (println "Customer hasn't bought anything")
                (println (format "%1s: $ %2.2f" name (reduce #(+ %1 (* (Integer/parseInt (get %2 3)) (Float/parseFloat (get-2d products (- (Integer/parseInt (get %2 2)) 1) 2)))) 0 purchases) ))
            )
            )
        (println "Press Enter to go back to menu:")
        (read-line)
        (recur customers products sales)
        )
    "5" (do
        (println "Enter product name:")
        (let [name (read-line)
            prod-id (get (get (filterv (fn [x] (= name (get x 1))) products) 0) 0)
            purchases (filterv (fn [x] (= prod-id (get x 2))) sales)]
            (println name ":" (reduce #(+ %1 (Integer/parseInt (get %2 3))) 0 purchases)))
        (println "Press Enter to go back to menu:")
        (read-line)
        (recur customers products sales)
        )
    "6" (println "Exiting. Goodbye")
    (recur customers products sales) ;default case
    )
    )
)


(defn main []
    (main-loop (db/read-my-file "cust.txt") (db/read-my-file "prod.txt") (db/read-my-file "sales.txt"))
)

(main)