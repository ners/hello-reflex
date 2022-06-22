{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

--import Reflex.Dom
import UI
import UI.Class
import UI.Input
import UI.Layout
import UI.Text
import UI.Theme
import UI.View
import UI.Icons
import Text.Read (readMaybe)

instance Theme UI where
    primaryColor = Blue

toC :: Double -> Double
toC f = (f - 32) * (5 / 9);

toF :: Double -> Double
toF c = c * (9 / 5) + 32;

toMi :: Double -> Double
toMi = (/ 1.60934)

toKm :: Double -> Double
toKm = (* 1.60934)

toLb :: Double -> Double
toLb = (* 2.205)

toKg :: Double -> Double
toKg = (/ 2.205)

liftText :: (Read a, Show b) => (a -> b) -> Text -> Text
liftText f = pack . (maybe "" show) . (f <$>) . readMaybe . unpack

main :: IO ()
main = mainUI do
    tabView "Temperature"
        [ ("Temperature", heart)
        , ("Distance", collection)
        , ("Mass", note)
        ] True \case
            "Temperature" ->
                contentView $ hstack mdo
                    f <- inputE "Fahrenheit" $ liftText toF <$> c
                    p $ text "F"
                    c <- inputE "Celsius" $ liftText toC <$> f
                    p $ text "C"
                    pure ()
            "Distance" ->
                contentView $ hstack mdo
                    mi <- inputE "Miles" $ liftText toMi <$> km
                    p $ text "mi"
                    km <- inputE "Kilometres" $ liftText toKm <$> mi
                    p $ text "km"
                    pure ()
            "Mass" ->
                contentView $ hstack mdo
                    lb <- inputE "Pounds" $ liftText toLb <$> kg
                    p $ text "lb"
                    kg <- inputE "Kilograms" $ liftText toKg <$> lb
                    p $ text "kg"
                    pure ()
            _ -> contentView $ p $ text "Not implemented"
