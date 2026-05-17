#lang brag

command : verb-phrase 
        | verb-phrase noun-phrase
        | verb-phrase noun-phrase prep noun-phrase

verb-phrase : VERB

noun-phrase : NOUN
            | ARTICLE NOUN
            | ARTICLE NOUN NOUN

prep : PREP