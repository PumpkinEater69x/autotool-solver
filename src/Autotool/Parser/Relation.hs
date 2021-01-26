module Autotool.Parser.Relation ( parseIntRelation, parseRelation ) where

import Data.Either (fromRight)
import Text.Parsec ((<|>))
import qualified Text.Parsec as P
import qualified Data.Set as S

-- TODO: clear naming of Parse parser instance and string returning parser

parseIntRelation :: String -> S.Set (Integer,Integer)
parseIntRelation = fromRight undefined . P.parse parseRelation ""


parseRelation :: (Monad a) => P.ParsecT String u a (S.Set (Integer, Integer))
parseRelation = P.try parseEmpty <|> parseNonEmpty
    where
        parseEmpty = P.string "{}" >> return S.empty
        parseNonEmpty = P.between (P.char '{') (P.char '}') parseValues
        parseValues = S.fromList <$> P.sepBy1 parseTuple sep
        parseTuple = (,) <$> (P.char '(' *> parseInt) <*> (sep *> parseInt <* P.char ')')
        parseInt = (read :: [Char] -> Integer) <$> (P.spaces *> P.many1 P.digit <* P.spaces)
        sep = P.spaces >> P.char ',' >> P.spaces