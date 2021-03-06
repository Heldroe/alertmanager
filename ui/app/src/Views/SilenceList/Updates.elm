module Views.SilenceList.Updates exposing (update, urlUpdate)

import Silences.Api as Api
import Views.SilenceList.Types exposing (SilenceListMsg(..), Model)
import Utils.Types as Types exposing (ApiData, ApiResponse(Failure, Loading, Success), Time, Matchers)
import Utils.Filter exposing (Filter, generateQueryString)
import Views.FilterBar.Updates as FilterBar


update : SilenceListMsg -> Model -> Filter -> ( Model, Cmd SilenceListMsg )
update msg model filter =
    case msg of
        SilencesFetch sils ->
            ( { model | silences = sils }, Cmd.none )

        FetchSilences ->
            ( { model
                | filterBar = FilterBar.setMatchers filter model.filterBar
                , silences = Loading
              }
            , Api.getSilences filter SilencesFetch
            )

        DestroySilence silence ->
            -- TODO: "Deleted id: ID" growl
            -- TODO: Check why POST isn't there but is accepted
            ( { model | silences = Loading }
            , Api.destroy silence (always FetchSilences)
            )

        MsgForFilterBar msg ->
            let
                ( filterBar, cmd ) =
                    FilterBar.update "/#/silences" filter msg model.filterBar
            in
                ( { model | filterBar = filterBar }, Cmd.map MsgForFilterBar cmd )

        SetTab tab ->
            ( { model | tab = tab }, Cmd.none )


urlUpdate : Maybe String -> ( SilenceListMsg, Filter )
urlUpdate maybeString =
    ( FetchSilences, updateFilter maybeString )


updateFilter : Maybe String -> Filter
updateFilter maybeFilter =
    { receiver = Nothing
    , showSilenced = Nothing
    , group = Nothing
    , text = maybeFilter
    }
