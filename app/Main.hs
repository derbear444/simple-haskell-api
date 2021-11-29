-- Let's String literals be converted to ByteStrings
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}

import Data.Aeson
import Network.HTTP.Simple
import Data.ByteString as BS
import GHC.Generics
import Data.List.Split -- Might switch out for my own implementation
-- Used to convert Strings to ByteStrings and vice versa
import Data.ByteString.UTF8 (fromString, toString)
import Data.ByteString.Char8 as DBC (putStrLn)
import Data.ByteString.Lazy (fromStrict)

data Firebase = Firebase {
      apiKey :: String,
      authDomain :: String,
      databaseURL :: String,
      projectId :: String,
      storageBucket :: String,
      messagingSenderId :: String,
      appId :: String,
      measurementId :: String
    }
    deriving (Generic, ToJSON, FromJSON, Show)

firebaseInit :: Firebase
firebaseInit = Firebase {
      apiKey = "AIzaSyCkNMj_Jbdmi8cLsRY1SOp-BGcm8sKx2po",
      authDomain = "appallocate-cad69.firebaseapp.com",
      databaseURL = "https://appallocate-cad69-default-rtdb.firebaseio.com",
      projectId = "appallocate-cad69",
      storageBucket = "appallocate-cad69.appspot.com",
      messagingSenderId = "969023605323",
      appId = "1:969023605323:web:33552bcccf1c762cdd9bce",
      measurementId = "G-0822M01Z2B"
    }

------

testRequest = setRequestMethod "GET"
    $ setRequestHost "appallocate-cad69-default-rtdb.firebaseio.com"
    $ setRequestPath "/users.json?print=pretty"
    $ setRequestSecure True
    $ setRequestPort 443
    $ defaultRequest


defaultR = setRequestMethod "GET"
         $ setRequestHost "httpbin.org"
         $ setRequestPath "/get"
         $ setRequestSecure True
         $ setRequestPort 443
         $ defaultRequest

splitString :: Char -> String -> [String] -> [String] -- Currently doesn't work correctly
splitString c [] [] = []
-- splitString c (s:ss) acc = if c == s then acc ++ splitString c ss acc else [s] : splitString c ss acc
splitString c (s:ss) acc | c == s = splitString c ss acc
                         | otherwise = ([s] : acc) ++ splitString c ss acc

flatten :: [[Char]] -> [Char]
flatten [] = []
flatten [[a]] = [a]
flatten (x:xs) = '/' : x ++ flatten(xs)

createRequest :: ByteString -> ByteString -> ByteString -> ByteString -> Request
createRequest prot h m p = case prot of
                        "https" -> setRequestMethod m
                                  $ setRequestHost h
                                  $ setRequestPath p
                                  $ setRequestPort 443
                                  $ setRequestSecure True
                                  $ defaultRequest
                        "http" -> setRequestMethod m
                                  $ setRequestHost h
                                  $ setRequestPath p
                                  $ defaultRequest

createPostRequest :: ByteString -> ByteString -> ByteString -> ByteString -> ByteString -> Request
createPostRequest prot h m p b = case prot of
                            "https" -> setRequestMethod m
                                      $ setRequestHost h
                                      $ setRequestPath p
                                      $ setRequestPort 443
                                      $ setRequestSecure True
                                      $ setRequestBodyLBS (fromStrict b)
                                      $ defaultRequest
                            "http" -> setRequestMethod m
                                      $ setRequestHost h
                                      $ setRequestPath p
                                      $ setRequestBodyLBS (fromStrict b)
                                      $ defaultRequest

-- Let's a user run the GET function with a normal String
simpleGetWrapper :: String -> IO ()
simpleGetWrapper s = simpleGet (fromString s)

-- SIMPLE GET
simpleGet :: ByteString -> IO ()
simpleGet s = do
    response <- httpLbs request
    print (getResponseBody response)
    where request = setRequestMethod "GET"
            $ setRequestHost "appallocate-cad69.firebaseapp.com"
            $ setRequestPath s
            $ setRequestSecure True
            $ setRequestPort 443
            $ defaultRequest
    
checkMethod :: ByteString -> Bool
checkMethod s = case toString s of
                "GET" -> True
                "POST" -> True
                _ -> False

main :: IO ()
main = do
    Prelude.putStrLn "Please enter a valid URI (Ex. https://google.com/path):"
    uri <- BS.getLine
    let loop uri = do
        Prelude.putStrLn "Please enter a command:"
        commandInput <- Prelude.getLine
        case words commandInput of
            ("default" : _) -> do
                Prelude.putStrLn "Getting default response..."
                response <- httpLbs testRequest
                print (getResponseBody response)
                loop uri
            ("get" : _) -> do
                -- Splits the URI into the protocol, host and path
                let parsedProt = splitOn ":" (toString uri)
                    protocol = fromString (Prelude.head parsedProt)
                    parsedUri = splitOn "/" (Prelude.drop 2 (Prelude.last parsedProt))
                    host = fromString (Prelude.head parsedUri)
                    path = fromString (flatten (Prelude.tail parsedUri))
                    -- Sets the method to "GET"
                    methodInput = fromString ("GET")
                -- Prints the current host, method, and path
                Prelude.putStrLn "Attempting to make request with..." -- Should fix up this printing
                Prelude.putStrLn "Host: "
                DBC.putStrLn host
                Prelude.putStrLn "Method: "
                DBC.putStrLn methodInput
                Prelude.putStrLn "Path: "
                DBC.putStrLn path
                Prelude.putStrLn "Protocol: "
                DBC.putStrLn protocol
                -- Creates the response and then prints it
                response <- httpLbs (createRequest protocol host methodInput path)
                print (getResponseBody response)
                loop uri
            ("post" : _) -> do
                Prelude.putStrLn "Please enter the body of the request in JSON:"
                body <- BS.getLine
                let parsedProt = splitOn ":" (toString uri)
                    protocol = fromString (Prelude.head parsedProt)
                    parsedUri = splitOn "/" (Prelude.drop 2 (Prelude.last parsedProt))
                    host = fromString (Prelude.head parsedUri)
                    path = fromString (flatten (Prelude.tail parsedUri))
                    -- Sets the method to "GET"
                    methodInput = fromString ("POST")
                -- Prints the current host, method, path, and body
                Prelude.putStrLn "Attempting to make request with..." -- Should fix up this printing
                Prelude.putStrLn "Host: "
                DBC.putStrLn host
                Prelude.putStrLn "Method: "
                DBC.putStrLn methodInput
                Prelude.putStrLn "Path: "
                DBC.putStrLn path
                Prelude.putStrLn "Protocol: "
                DBC.putStrLn protocol
                Prelude.putStrLn "Body: "
                DBC.putStrLn body
                -- Creates the response and then prints it
                response <- httpLbs (createPostRequest protocol host methodInput path body)
                print (getResponseBody response)
                loop uri
            ("new" : _) -> do
                Prelude.putStrLn "Please enter a new URI:"
                newUri <- BS.getLine
                loop newUri
            ("show" : _) -> do
                Prelude.putStrLn "Current URI:"
                DBC.putStrLn uri
                loop uri
            ("quit" : _) -> return ()
            _ -> Prelude.putStrLn "Parse error!" >> loop uri
    loop uri
