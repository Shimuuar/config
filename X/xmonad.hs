--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import Codec.Binary.UTF8.String

import qualified Data.Map as M
import Data.Ratio ((%))

import System.Exit
import System.IO

-- XMonad part ----------------
import XMonad
import qualified XMonad.StackSet as W

import XMonad.Actions.SinkAll

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks

import qualified XMonad.Layout.IM as IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders

import XMonad.Util.Run
import XMonad.Util.Scratchpad
import XMonad.Util.EZConfig

import XMonad.Prompt

----------------------------------------------------------------

-- | Data for XPrompt 
data XPDict = XPDict
instance XPrompt XPDict where
    showXPrompt = const "Посмотреть слово: "
-- | Look wod in dictionary 
lookupDictionary :: XPConfig -> X ()
lookupDictionary config = mkXPrompt XPDict config (return . const []) 
    ((\x -> spawnU $ "(echo "++x++"; dict "++x++") | dzen_less") . shellEscape)


-- | Escapes all shell metacharacters.
shellEscape :: String -> String 
shellEscape = concatMap (\x -> if x `elem` " ;$!@#%&|<>" then '\\':[x] else [x])
 
-- | Unicode safe spawn 
spawnU :: MonadIO m => String -> m ()
spawnU = spawn . encodeString

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = 
  let upperKeys = ["1","2","3","4","5","6","7","8","9","0","-","="]
  in mkKeymap conf $
    -- Switch to workspace 
    [ ("M-"   ++ key, windows $ W.greedyView ws) |
      (key,ws) <- zip upperKeys (XMonad.workspaces conf) ]
    ++ 
    -- Move window to workspace
    [ ("M-S-" ++ key, windows $ W.shift ws) |
      (key,ws) <- zip upperKeys (XMonad.workspaces conf) ]
    ++
    [ -- Quit XMonad
      ("M-S-q"       , io (exitWith ExitSuccess))
    -- Restart XMonad
    , ("M-q"         , broadcastMessage ReleaseResources >> restart "xmonad" True)
    -- Run termnal emulator 
    , ("M-S-<Return>", spawn $ XMonad.terminal conf)
    -- Run menu
    , ("M-p"         , spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    -- Close focused window 
    , ("M-S-c"       , kill)
    -- Rotate through the available layout algorithms
    , ("M-<Space>"   , sendMessage NextLayout)
    -- Reset the layouts on the current workspace to default
    , ("M-S-<Space>" , setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size 
    , ("M-n"         , refresh)
    -- Move focus to the next/prev window
    , ("M-<Tab>"     , windows W.focusDown)
    , ("M-<Left>"    , windows W.focusDown)
    , ("M-j"         , windows W.focusDown)
    , ("M-<Right>"   , windows W.focusUp)
    , ("M-k"         , windows W.focusUp)
    -- Move focus to the master window
    , ("M-m"         , windows W.focusMaster)
    -- Swap the focused window and the master window
    , ("M-<Return>"  , windows W.swapMaster)
    -- Swap the focused window with the next/prev window
    , ("M-S-j"       , windows W.swapDown)
    , ("M-S-k"       , windows W.swapUp)
    -- Shrink/expand the master area
    , ("M-h"         , sendMessage Shrink)
    , ("M-l"         , sendMessage Expand)
    -- Push window back into tiling
    , ("M-t"         , withFocused $ windows . W.sink)
    , ("M-<Down>"    , sinkAll)
    -- Inc/dec the number of windows in the master area
    , ("M-,"          , sendMessage (IncMasterN 1))
    , ("M-."          , sendMessage (IncMasterN (-1)))

    -- MPD keybindings 
    , ("M-<Page_Down>"   , spawn "mpc next   > /dev/null")
    , ("M-<Page_Up>"     , spawn "mpc prev   > /dev/null")
    , ("M-<End>"         , spawn "mpc toggle > /dev/null")
    , ("M-<Home>"        , spawn "mpc stop   > /dev/null")
    , ("M-<Insert>"      , spawn "mpc play   > /dev/null")
    , ("M-S-<Delete>"    , spawn "mpc del 0  > /dev/null")
    , ("M-M1-S-<Delete>" , spawn "mpc clear  > /dev/null")

    -- Applications shortcuts
    , ("M-M1-e"  , spawn "emacs")
    , ("M-M1-i"  , spawn "iceweasel")
    , ("M-M1-k"  , spawn "konqueror")
    , ("M-M1-w"  , spawn "kdesu wireshark")
    , ("M-s"     , spawn "xterm -name scratchpad -e sh -c 'screen -d -R scratch'")
    -- Useful action 
    , ("M-M1-a" , spawn "fmt ~/.local/share/apod/description | dzen_less")
    , ("M-d"    , spawn "look_dictionary | dzen_less")
    , ("M-S-d"  , lookupDictionary myXPconfig )
    , ("M-z"    , spawn "dzen_less -e < ~/.xsession-errors")
    , ("M-i"    , spawn "iceweasel \"$(xsel)\"")
    ]
  
 
------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Events:
myHandleEventHook = ewmhDesktopsEventHook
 
------------------------------------------------------------------------
-- Layouts:
 
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
myLayout = smartBorders $
           avoidStruts  $ 
           onWorkspace "IM" (IM.IM (1%5) (IM.Resource "main")) $
           tiled ||| Mirror tiled ||| Full
    where
      -- default tiling algorithm partitions the screen into two panes
      tiled   = Tall nmaster delta ratio
      -- The default number of windows in the master pane
      nmaster = 1
      -- Default proportion of screen occupied by master pane
      ratio   = 1/2
      -- Percent of screen to increment by when resizing panes
      delta   = 3/100
 
------------------------------------------------------------------------
-- Window rules:
-- 
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll $ concat [
    -- Floating windows 
    [ className =? c --> doFloat       | c <- ["Gimp"]],
    [ className =? c --> doCenterFloat | c <- ["XDosEmu", "feh"]],
    [ className =? c --> doFullFloat   | c <- ["wesnoth", "MPlayer"]],
    -- Ignored windows 
    [ className =? c --> doIgnore       | c <- ["stalonetray", "trayer", "fbpanel", "xfce4-panel", "Xfce4-panel"]],
    [ resource  =? c --> doIgnore       | c <- ["desktop_window", "kdesktop"]],
    -- ignore Kicker and float kicker's calendar
    [ (className =? "Kicker" <&&> title =? "kicker")   --> doIgnore 
    , (className =? "Kicker" <&&> title =? "Calendar") --> doFloat ],
    -- Other hooks 
    [ className =? "Akregator"      --> doF (W.shift "RSS")
    , className =? "psi"            --> doF (W.shift "IM")
    , className =? "Sonata"         --> doF (W.shift "Муз")
    , className =? "Ktorrent"       --> doF (W.shift "Торр") ],
    [ className =? c --> (doF $ W.shift "WWW") 
                | c <- ["Iceweasel", "Firefox-bin", "Firefox"]],
    -- Scratchpad hook
    [ scratchpadManageHook $ W.RationalRect (1%8) (1%6) (6%8) (2%3) ]
    ]
 

------------------------------------------------------------------------
-- XPromt settings 
myXPconfig = defaultXPConfig { 
               font = "-xos4-terminus-medium-r-normal-*-16-160-*-*-*-*-iso10646-*" 
             }


----------------------------------------------------------------
-- XMonad config
myConfig = defaultConfig {
      -- simple stuff
      terminal           = "my-terminal",  -- Supposed to be symlink to actual terminal emulator
      modMask            = mod4Mask,
      focusFollowsMouse  = True,
      borderWidth        = 1,
      workspaces         = ["1","2","WWW","Муз","Mail","Торр","7","RSS","IM","--"],
      normalBorderColor  = "#dddddd",
      focusedBorderColor = "#ff0000",
      -- key bindings
      keys               = myKeys,
      mouseBindings      = myMouseBindings,
      -- hooks, layouts
      handleEventHook    = myHandleEventHook,
      layoutHook         = myLayout,
      manageHook         = myManageHook,
      logHook            = ewmhDesktopsLogHook
      }


------------------------------------------------------------------------
-- Run xmonad
main = xmonad myConfig
