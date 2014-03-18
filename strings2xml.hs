import Text.ParserCombinators.Parsec
import Data.Maybe
import Control.Monad

eol =     try (string "\n\r")
      <|> try (string "\r\n")
      <|> string "\n"
      <|> string "\r"

str = between (char '\"') (char '\"') $ many $ noneOf "\""

comment = string "/*" >> manyTill anyChar (string "*/")

key = try key' <|> key_
    where key' = str
          key_ = many1 $ noneOf " \t="

keyvalue = liftM5 g k eq v comma nl
    where k = key <?> "key"
          v = str <?> "value"
          eq = between spaces spaces (char '=')
          comma = char ';' <?> "comma"
          nl = eol
          g x _ y _ _ = (x, y)

line = spaces >> (try (comment >> return Nothing) <|> try (liftM Just keyvalue))

file = liftM catMaybes $ many line

gen xs = ("<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\">" ++ s) ++ "</plist>"
    where f x y = x ++ g y
          g (k,v) = "<key>" ++ k ++ "</key>" ++ "<string>" ++ v ++ "</string>"
          s = "<dict>" ++ foldl f "" xs ++ "</dict>"

main :: IO ()
main = do c <- getContents
          case parse file "(stdin)" c of
            Left e -> do putStrLn "error parsing input:"
                         print e
            Right r -> putStrLn $ gen r
