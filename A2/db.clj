(ns db
  (:require [clojure.string :as s]))

(defn read-my-file [filename]
    (let [content (s/split-lines (slurp filename))
          ordered (sort content)]
          (mapv #(s/split % #"\|") ordered)
    )
)