{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid
import           Hakyll
import           Hakyll.Web.Sass
import           Text.Sass.Options

main :: IO ()
main = hakyllWith config $ do

  match "templates/*" $
    compile templateCompiler

  match "css/main.scss" $ do
    route $ setExtension ".css"
    compile $ sassCompilerWith $ sassDefConfig { sassIncludePaths = Just ["css"] }

  match "posts/*" $ do
    route $ setExtension ".html"
    compile $ do
      pandocCompiler
        >>= return . fmap demoteHeaders
        >>= loadAndApplyTemplate "templates/post.html" defaultContext
        >>= loadAndApplyTemplate "templates/content.html" defaultContext
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

  create ["posts.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let ctx = constField "title" "Posts" <>
            listField "posts" defaultContext (return posts) <>
            defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/posts.html" ctx
        >>= loadAndApplyTemplate "templates/content.html" defaultContext
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

config :: Configuration
config = defaultConfiguration
