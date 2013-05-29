Revision_necessity_score = lambda {|s|
  ask_human_choose_one("Please mark text that needs revision.", s, ["Well-written and understandable.", "Needs work."], {samples: 3}).count("Needs work.") / 3.0
}
Finegrained_revision_necessity_score = lambda {|s|
  ask_human_choose_one("Please mark text that needs revision.", s, ["Well-written and understandable.", "Needs work."], {samples: 10}).count("Needs work.") / 10.0
}
Literary_revision_necessity_score = lambda {|s|
  ask_human_choose_one("Please mark text that needs revision. (This will not cause any other Turker's work to be rejected.)", s, ["Well-written, understandable, interesting to read", "Needs work."], {samples: 8}).count("Needs work.") / 8.0
}
Literary_revision_desire_score = lambda {|s|
  ask_human_choose_one("Please mark text that could be improved. (This will not cause any other Turker's work to be rejected.)", s, ["Grammatical, understandable, interesting to read", "Could be improved."], {samples: 8}).count("Could be improved.") / 8.0
}
Finegrained_literary_revision_desire_score = lambda {|s|
  ask_human_choose_one("Please mark text that could be improved. (This will not cause any other Turker's work to be rejected.)", s, ["Grammatical, understandable, interesting to read", "Could be improved."], {samples: 20}).count("Could be improved.") / 20.0
}

GoodWriting1 = "As of Dec 6, corn sales for delivery before Sept 1 fell 46 percent to 12.488 million tons from a year earlier, the lowest since the US Department of Agriculture began reporting the data in 1990. Output of grain-based ethanol, a gasoline additive, fell 1.3 percent in the week ended Dec 7 from a week earlier, and inventories rose to the highest since June 29, US Energy Department data show. Corn futures for March delivery declined 1.1 percent to $7.23 a bushel at 10:21am on the Chicago Board of Trade. A close at that level would mark the biggest drop since Dec 7. The price through Dec 14 gained 13 percent this year after drought cut US production 13 percent to a six-year low."
BadWriting1 = "Above all, we cannot play ducks and drakes with a native battery of idioms which prescribes egregious collocations of vocables as the Basic 'put up with' for 'tolerate', or 'put at a loss' for bewilder."
GoodWriting2 = "If personality is an unbroken series of successful gestures, then there was something gorgeous about him, some heightened sensitivity to the promises of life, as if he were related to one of those intricate machines that register earthquakes ten thousand miles away. This responsiveness had nothing to do with that flabby impressionability which is dignified under the name of the 'creative temperament'--it was an extraordinary gift for hope, a romantic readiness such as I have never found in any other person and which it is not likely I shall ever find again. No--Jay turned out all right at the end; it is what preyed on Jay, what foul dust floated in the wake of his dreams that temporarily closed out my interest in the abortive sorrows and short-winded elations of men."
BadWriting2 = "I am not, indeed, sure whether it is not true to say that the Milton who once seemed not unlike a seventeenth-century Shelley had not become, out of an experience ever more bitter in each year, more alien to the founder of that Jesuit sect which nothing could induce him to tolerate."
GoodWriting3 = "If one day it happens you find yourself with someone you love in a cafe at one end of the Pont Mirabeau, at the zinc bar where white wine stands in upward opening glasses, and if you commit then, as we did, the error of thinking, one day all this will only be memory, learn, as you stand at this end of the bridge which arcs,from love, you think, into enduring love, learn to reach deeper into the sorrows to come - to touch the almost imaginary bones under the face, to hear under the laughter the wind crying across the black stones. Kiss the mouth which tells you, here,here is the world."
BadWriting3 = "This is where the love letter ends, and the sales rep who was prepping a pull-quote for their front page closes his editor. While we love the service and couldn't have got where we are without it, it's important to be honest that not everything is sunshine and roses."
GoodWritingDescription = "Has correct grammar, has proper word usage, has balanced sentence structure, has no overly-common metaphors/similes/figures of speech, has no overly complex words, is not wordy, avoids passive voice when possible, makes a point, and makes its point clearly."
BadWritingDescription = "Could use another revision."

ShortGoodWritingDescription = "Well-written."
ShortBadWritingDescription = "Needs a revision."

WritingGoldStandards = [[GoodWriting1, ShortGoodWritingDescription, ShortBadWritingDescription], [BadWriting1, ShortBadWritingDescription, ShortGoodWritingDescription], [GoodWriting2, ShortGoodWritingDescription, ShortBadWritingDescription], [BadWriting2, ShortBadWritingDescription, ShortGoodWritingDescription], [GoodWriting3, ShortGoodWritingDescription, ShortBadWritingDescription], [BadWriting3, ShortBadWritingDescription, ShortGoodWritingDescription]]

Compassionate_revision_necessity_score = lambda {|s, gss|
  ask_human_choose_one("Please mark text that can be improved. (This will not cause any Turker's work to be rejected.)", s, [GoodWritingDescription, BadWritingDescription], gss, {samples: 10}).count(BadWritingDescription) / 10.0
}
Sentence_rewrites = lambda {|q,t|
  ask_human_text("Please rewrite the following sentences to make them easier to understand.", q, t, :samples => 3)
}
Paragraph_rewrites = lambda {|q,t|
  ask_human_text("The following paragraphs are hard to understand; please revise them.", q, t, :samples => 3)
}
Give_context = lambda {|pre, guts, post|
  (pre.nil? ? "" : (pre + "\n\n----^--(just-before-the-text)----\n\n")) + guts + (post.nil? ? "" : ( "----v--(just-after-the-text)----\n\n" + post))
}
Split_sentences = lambda {|s|
  s.split(/(?<! [A-Z]\w[.!?])(?<! [A-Z]\w\w[.!?])(?<! [A-Z]\w\w\w[.!?])(?<=[.!?]) +(?=[A-Z])|\n+/)
}
Split_paragraphs = lambda {|s|
  s.split(/\n+/)
}
Choose_revision = lambda {|s,rs|
  ask_human_choose_one("Please choose the best revision of a passage.", s, rs, :samples => 3)
}
Improve = lambda {|text, splitter, necessity_score, rewriter, chooser, joiner|
  splitted = splitter[text]
  better_splitted = (0...splitted.size).pmap(splitted.size) {|i|
    pre = i > 0 ? splitted[i-1] : nil
    guts = splitted[i]
    post = i > (sentences.size - 1) ? nil : sentences[i+1]
    contextualized = Give_context[pre,guts,post]
    necessity_score[guts].zero? ? guts : choose[ [guts] + rewriter[contextualized, guts] ]
  }
  joiner[better_splitted]
}
Improve_sentences = lambda {|text|
  improve[ text, Split_sentences, Revision_necessity_score, Sentence_rewrites, Choose_revision, lambda {|a| a.join(' ') } ]
}
Improve_paragraphs = lambda {|text|
  improve[ text, Split_paragraphs, Revision_necessity_score, Paragraph_rewrites, Choose_revision, lambda {|a| a.join("\n\n") } ]
}

  
