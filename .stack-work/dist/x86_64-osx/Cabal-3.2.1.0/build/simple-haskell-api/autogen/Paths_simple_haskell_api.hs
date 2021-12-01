{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_simple_haskell_api (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/bin"
libdir     = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/lib/x86_64-osx-ghc-8.10.7/simple-haskell-api-0.1.0.0-ABB4tPstxLZEcbAUehXb7O-simple-haskell-api"
dynlibdir  = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/lib/x86_64-osx-ghc-8.10.7"
datadir    = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/share/x86_64-osx-ghc-8.10.7/simple-haskell-api-0.1.0.0"
libexecdir = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/libexec/x86_64-osx-ghc-8.10.7/simple-haskell-api-0.1.0.0"
sysconfdir = "/Users/derek/Documents/CS-3490/final/simple-haskell-api/.stack-work/install/x86_64-osx/9cd23998bfec06eb2bc56ea3e19a5f448712312ceddbc5ed67265ae5574bfdeb/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "simple_haskell_api_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "simple_haskell_api_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "simple_haskell_api_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "simple_haskell_api_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "simple_haskell_api_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "simple_haskell_api_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
