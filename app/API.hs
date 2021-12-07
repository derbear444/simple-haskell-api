-- Let's String literals be converted to ByteStrings
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Exception
import Network.HTTP.Simple
import Data.ByteString as BS
-- Used to convert Strings to ByteStrings and vice versa
import Data.ByteString.UTF8 (fromString, toString)
import Data.ByteString.Char8 as DBC (putStrLn)
import Data.ByteString.Lazy (fromStrict)
import Data.List.Split -- Might switch out for my own implementation

------

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
    where request = setRequestMethod "DELETE"
            $ setRequestHost "appallocate-cad69.firebaseapp.com"
            $ setRequestPath s
            $ setRequestSecure True
            $ setRequestPort 443
            $ defaultRequest
    
-- Used to make sure the URI is valid. Throws an error if it is not valid.
checkUri :: ByteString -> IO ()
checkUri s = let uri = toString s
                 parsedProt = splitOn ":" uri
                 protocol = fromString (Prelude.head parsedProt)
             in 
                 if (protocol == "https" || protocol == "http" || protocol == "quit") then return () else error "No!"

commands :: String
commands = "List of commands:\ndefault, get, delete, post, new, show, commands, quit"

main :: IO ()
main = do
    Prelude.putStrLn "Please enter a valid URI (Ex. https://dog.ceo/api/breeds/list/all):"
    uri <- BS.getLine
    -- Checks if the uri is quit and immediately stops
    if (toString uri) == "quit" then return ()
    else do
        check <- catch (checkUri uri) handler
        let loop uri = do
                    Prelude.putStrLn "Please enter a command:"
                    commandInput <- Prelude.getLine
                    case words commandInput of
                            ("default" : _) -> do
                                Prelude.putStrLn "Getting default response..."
                                response <- httpLbs defaultR
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
                                Prelude.putStrLn "--------------------------"
                                print (getResponseBody response)
                                loop uri
                            ("delete" : _) -> do
                                Prelude.putStrLn "Please enter an item to remove:"
                                removal <- BS.getLine
                                -- Splits the URI into the protocol, host and path
                                let parsedProt = splitOn ":" (toString uri)
                                    protocol = fromString (Prelude.head parsedProt)
                                    parsedUri = splitOn "/" (Prelude.drop 2 (Prelude.last parsedProt))
                                    host = fromString (Prelude.head parsedUri)
                                    path = fromString (flatten (Prelude.tail parsedUri))
                                    -- Sets the method to "GET"
                                    methodInput = fromString ("DELETE")
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
                                Prelude.putStrLn "Item to Remove: "
                                DBC.putStrLn removal
                                -- Creates the response and then prints it
                                response <- httpLbs (createRequest protocol host methodInput (path <> removal))
                                Prelude.putStrLn "--------------------------"
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
                                Prelude.putStrLn "--------------------------"
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
                            ("commands" : _) -> do
                                Prelude.putStrLn commands
                                loop uri
                            ("quit" : _) -> return ()
                            _ -> Prelude.putStrLn "Parse error!" >> loop uri
        loop uri
    where handler :: SomeException -> IO ()
          handler ex = Prelude.putStrLn "Invalid URI!" >> main