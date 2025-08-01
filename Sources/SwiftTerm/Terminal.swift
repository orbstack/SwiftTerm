//
//  Terminal.swift
//  SwiftTerm
//
//  Created by Miguel de Icaza on 3/27/19.
//  Copyright © 2019 Miguel de Icaza. All rights reserved.
//
// TODO: review every place that sets cursor to use setCursor
// TODO: audit every location to use restrictCursor

import Foundation

/**
 * The terminal delegate is a protocol that must be implemented by a class
 * that would provide a user interface for the terminal, and it is used by the
 * `Terminal` to notify of important changes on the underlying terminal
 */
public protocol TerminalDelegate: AnyObject {
    /**
     * Invoked to request that the cursor be shown
     */
    func showCursor (source: Terminal)

    /**
     * Invoked to request that the cursor be shown
     */
    func hideCursor (source: Terminal)

    /**
     * This method is invoked when the terminal needs to set the title for the window,
     * a UI toolkit would react by setting the terminal title in the window or any other
     * user visible element.
     *
     * The default implementation does nothing.
     */
    func setTerminalTitle (source: Terminal, title: String)

    /**
     * This method is invoked when the terminal needs to set the title for the minimized icon,
     * a UI toolkit would react by setting the terminal title in the icon or any other
     * user visible element
     *
     * The default implementation does nothing.
     */
    func setTerminalIconTitle (source: Terminal, title: String)

    /**
     * These are various commands that are sent by the client.  They are rare,
     * and if you do not know what to return, just return nil, the terminal
     * will return a suitable value.
     *
     * The response string needs to be suitable for the Xterm CSI Ps ; Ps ; Ps t command
     * see the WindowManipulationCommand enumeration for those that need to return values
     *
     * The default implementation does nothing.
     */
    @discardableResult
    func windowCommand (source: Terminal, command: Terminal.WindowManipulationCommand) -> [UInt8]?
    
    /**
     * This method is invoked when the terminal dimensions have changed in response
     * to an escape sequence that triggers a terminal resize, the user interface toolkit
     * should attempt to accomodate the new window size
     *
     * TODO: This is not wired up
     *
     * The default implementation does nothing.
     */
    func sizeChanged (source: Terminal)
    
    /**
     * Sends the byte data to the client connected to the terminal (in terminal emulation
     * documentation, this is the "host")
     */
    func send (source: Terminal, data: ArraySlice<UInt8>)
    
    // callbacks
    
    /// Callback - the window was scrolled, new yDisplay passed
    /// The default implementation does nothing.
    func scrolled (source: Terminal, yDisp: Int)
    
    /// Callback a newline was generated
    /// The default implementation does nothing.
    func linefeed (source: Terminal)
    
    /// This method is invoked when the buffer changes from Normal to Alternate, or Alternate to Normal
    /// The default implementation does nothing.
    func bufferActivated (source: Terminal)
    
    /// Should raise the bell
    /// The default implementation does nothing.
    func bell (source: Terminal)
    
    /**
     * This is invoked when the selection has changed, or has been turned on.   The status is
     * available in `terminal.selection.active`, and the range relative to the buffer is
     * in `terminal.selection.start` and `terminal.selection.end`
     *
     * The default implementation does nothing.
     */
    func selectionChanged (source: Terminal)
    
    /**
     * This method should return `true` if operations that can read the buffer back should be allowed,
     * otherwise, return false.   This is useful to run some applications that attempt to checksum the
     * contents of the screen (unit tests)
     *
     * The default implementation returns `true`
     */
    func isProcessTrusted (source: Terminal) -> Bool
    
    /**
     * This method is invoked when the `mouseMode` property has changed, and gives the UI
     * a chance to update any tracking capabilities that are required in the toolkit or no longer
     * required to provide the events.
     *
     * The default implementation ignores the mouse change
     */
    func mouseModeChanged (source: Terminal)
    
    /**
     * This method is invoked when a request to change the cursor style has been issued
     * by client application.
     */
    func cursorStyleChanged (source: Terminal, newStyle: CursorStyle)
    
    /**
     * This method is invoked when the client application has issued a command to report
     * its current working directory (this is done with the OSC 7 command).   The value can be
     * read by accessing the `hostCurrentDirectory` property.
     *
     * The default implementaiton does nothing.
     */
    func hostCurrentDirectoryUpdated (source: Terminal)
    
    /**
     * This method is invoked when the client application has issued a command to report
     * its current document (this is done with the OSC 6 command).   The value can be
     * read by accessing the `hostCurrentDocument` property.
     *
     * The default implementaiton does nothing.
     */
    func hostCurrentDocumentUpdated (source: Terminal)
    
    /**
     * This method is invoked when a color in the 0..255 palette has been redefined, if the
     * front-end keeps a cache or uses indexed rendering, it should update the color
     * with the new values.   If the value of idx is nil, this means all the ansi colors changed
     */
    func colorChanged (source: Terminal, idx: Int?)
    
    /**
     * The view should try to set the foreground color to the provided color
     */
    func setForegroundColor (source: Terminal, color: Color)
    
    /**
     * The view should try to set the background color to the provided color
     */
    func setBackgroundColor (source: Terminal, color: Color)
    
    /**
     * The view should try to set the cursor color to the provided color.   If color is nil, the view can use a default.
     */
    func setCursorColor (source: Terminal, color: Color?)
    
    /**
     * This should return the current foreground and background colors to
     * report.
     */
    func getColors (source: Terminal) -> (foreground: Color, background: Color)
    
    /**
     * This method is invoked when the client application (iTerm2) has issued a OSC 1337 and
     * SwiftTerm did not handle a handler for it.
     *
     * The default implementaiton does nothing.
     */
    func iTermContent (source: Terminal, content: ArraySlice<UInt8>)
    
    /**
     * This method is invoked when the client application has issued a OSC 52
     * to put data on the clipboard.
     *
     * - Parameters:
     *  - source: identifies the instance of the terminal that sent this request
     *  - content: the data to place on the clipboard
     * The default implementation does nothing.
     */
    func clipboardCopy(source: Terminal, content: Data)
    
    /**
     * Invoked when client application issues OSC 777 to show notification.
     *
     * The default implementation does nothing.
     * - Parameters:
     *  - source: identifies the instance of the terminal that sent this request
     *  - title: the title to show for the notification
     *  - body: the body of the notification
     */
    func notify(source: Terminal, title: String, body: String)
    
    /**
     * Invoked to create an image from an RGBA buffer at the current cursor position
     *
     * The default implementation does nothing.
     * - Parameters:
     *  - source: identifies the instance of the terminal that sent this request
     *  - bytes: Image buffer in RGBA format, using 8 bits per channel.
     *  - width: the width in pixels of the image
     *  - height: the height in pixels of the image
     */
    func createImageFromBitmap (source: Terminal, bytes: inout [UInt8], width: Int, height: Int)
    
    /**
     * Invoked to create an image from a byte blob that might be encoded in one of the various
     * compressed file formats (unlike the other option that gets an RGBA buffer already decoded).
     * It also included requests for the desired dimensions.
     * - Parameters:
     *  - source: identifies the instance of the terminal that sent this request
     *  - data: Binary blob containing the image data, which is typically encoded as a PNG or JPEG file
     *  - widthRequest: the width requested, it contains an enumeration describing what the request was
     *  - height: the height requested, it contains an enumeration describing what the request was
     *  - preserveAspectRatio: if set, one of the dimensions will track the hardcoded setting set for the other.
     */
    func createImage (source: Terminal, data: Data, width: ImageSizeRequest, height: ImageSizeRequest, preserveAspectRatio: Bool)
}

/// Enumeration passed to the TerminalDelegate.createImage to configure
/// the desired values for width and height.
public enum ImageSizeRequest {
    /// Make the best decision based on the image data
    case auto
    /// Occupy exactly the number of cells
    case cells(Int)
    /// Occupy exactly the pixels listed
    case pixels(Int)
    /// Occupy a percentange size relative to the dimension of the visible region
    case percent(Int)
}

public protocol TerminalImage {
    /// The width of the image in pixels
    var pixelWidth: Int { get }
    /// The height of the image in pixels
    var pixelHeight: Int { get }
    
    /// Column where the image was attached
    var col: Int { get set }
}

/**
 * The `Terminal` class provides the terminal emulation engine, and can be used to feed data to the
 * terminal emulator.   Typically users will intereact with a higher-level implementation that provides a
 * UI toolkit-specific rendering and connects the input to the UI toolkit.
 *
 * A front-end would draw the contents of the terminal, and take input from the user, which is in turn
 * either mapped to one of the public APIs here, or if it is user input is passed to the `feed`  methods here.
 *
 * The terminal is also connected to a backend that is conneted to the client, and data from this
 * client is fed into the emulator by calling the `sendResponse method`
 *
 * The behavior of the terminal is configured by implementing the `TerminalDelegate` protocol
 * that is provided in the constructor call.
 */
open class Terminal {
    let MINIMUM_COLS = 2
    let MINIMUM_ROWS = 1
    
    /// The current terminal columns (counting from 1)
    public private(set) var cols: Int = 80
    
    /// The current terminal rows (counting from 1)
    public private(set) var rows: Int = 25
    var tabStopWidth : Int = 8
    
    /// Terminal configuration options.
    /// Setup(isReset:) method should be called to apply changes
    public var options: TerminalOptions
    
    // The current buffers
    var normalBuffer, altBuffer: Buffer
    /**
     * Returns the active buffer (either the normal buffer or the alternative buffer)
     */
    public private(set) var buffer: Buffer
    
    public var isCurrentBufferAlternate: Bool {
        buffer === altBuffer
    }
    
    // Whether the terminal is operating in application keypad mode
    var applicationKeypad : Bool = false
    
    // Whether the terminal is operating in application cursor mode
    public var applicationCursor : Bool = false
    
    // You can ignore most of the defaults set here, the function
    // reset() will do that again
    var sendFocus: Bool = false
    var cursorHidden : Bool = false
    
    /// Controls the origin mode (DECOM), when set, the screen is limited to the top and bottom margins
    var originMode: Bool = false
    
    /// Controls whether it is possible to set left and right margin modes
    var marginMode: Bool = false
    
    var insertMode: Bool = false
    
    var wraparound: Bool = false

    func setMarginMode(_ value: Bool) {
        marginMode = value
        normalBuffer.setMarginMode(value)
        altBuffer.setMarginMode(value)
    }

    func setInsertMode(_ value: Bool) {
        insertMode = value
        normalBuffer.setInsertMode(value)
        altBuffer.setInsertMode(value)
    }

    func setWraparound(_ value: Bool) {
        wraparound = value
        normalBuffer.setWraparound(value)
        altBuffer.setWraparound(value)
    }

    /// Indicates that the application has toggled bracketed paste mode, which means that when content is pasted into
    /// the terminal, the content will be wrapped in "ESC [ 200 ~" to start, and "ESC [ 201 ~" to end.
    public private(set) var bracketedPasteMode: Bool = false
    
    private var charset: [UInt8:String]? = nil
    var gcharset: Int = 0
    var reverseWraparound: Bool = false
    weak var tdel: TerminalDelegate?
    private var curAttr: Attribute = CharData.defaultAttr
    var gLevel: UInt8 = 0
    var cursorBlink: Bool = false
    
    var allow80To132 = true
    
    public var parser: EscapeSequenceParser
    
    var refreshStart = Int.max
    var refreshEnd = -1
    var scrollInvariantRefreshStart = Int.max
    var scrollInvariantRefreshEnd = -1
    var userScrolling = false
    var lineFeedMode = false
    
    // We do not implement smooth scrolling here, dubious value, but
    // makes a test bass
    var smoothScroll = false
    
    // Installed colors are the 16 values that can be changed dynamically by the host
    var installedColors: [Color]
    // The blueprint for the colors, computed based on the installed colors
    var defaultAnsiColors: [Color]
    // The active set of colors (based on the blueprint)
    var ansiColors: [Color]
    
    // Control codes provides an API to send either 8bit sequences or 7bit sequences for C0 and C1 depending on the terminal state
    var cc: CC
    
    /// This variable if set, contains an URI representing the host and directory of the process running in the terminal
    /// it is often used by applciations to track the working directory.   It might be nil, or might not be correct, the
    /// contents are entirely under the control of the remote application, and require the terminal to be trusted
    /// (see the `isProcessTrusted` method in the `TerminalDelegate`).  When this is set the
    /// `hostCurrentDirectoryUpdated` method on the delegate is invoked.
    public private(set) var hostCurrentDirectory: String? = nil
    
    /// This variable if set, contains an URI representing the host and current document of the process
    /// running in the terminal.   It might be nil, or might not be correct, the
    /// contents are entirely under the control of the remote application, and require the terminal to be trusted
    /// (see the `isProcessTrusted` method in the `TerminalDelegate`).  When this is set the
    /// `hostCurrentDocumentUpdated` method on the delegate is invoked.
    public private(set) var hostCurrentDocument: String? = nil
    
    /// The current attribute used by the terminal by default
    public var currentAttribute: Attribute {
        get { return curAttr }
    }
    // The requested conformance from DECSCL command
    enum TerminalConformance {
        case vt100
        case vt200
        case vt300
        case vt400
        case vt500
    }
    
    // The mouse coordinates can be encoded in a number of ways, and obey to historical
    // upgrades to the protocol, but also attempts at fixing limitations of the different
    // encodings.
    enum MouseProtocolEncoding {
        // The default x10 mode is limited to coordinates up to 223.
        // (255-32).   The other modes solve this limitaion
        case x10
        
        // Extends the range of a coordinate to 2015 by using UTF-8 encoding of the
        // coordinate value.   This encoding is troublesome for applications that
        // do not support utf8 input.
        case utf8
        
        // The response uses CSI < ButtonValue ; Px ; Py [Mm]
        case sgr

        // Different response style, with possible ambiguities, not recommended
        case urxvt
        
        // SGR with pixel precision
        case sgrPixel
    }
    
    // The protocol encoding for the terminal
    private var mouseProtocol: MouseProtocolEncoding = .x10

    // This is used to track if we are setting the colors, to prevent a
    // recursive invocation (nativeForegroundColor sets the terminal
    // color, which in turn broadcasts the request for a change)
    var settingFgColor = false, settingBgColor = false, settingCursorColor = false

    /// This tracks the current foreground color for the application.
    public var foregroundColor: Color = Color.defaultForeground {
        didSet {
            if settingFgColor {
                return
            }
            settingFgColor = true
            tdel?.setForegroundColor(source: self, color: foregroundColor)
            settingFgColor = false
        }
    }
    /// This tracks the current background color for the application.
    public var backgroundColor: Color = Color.defaultBackground {
        didSet {
            if settingBgColor {
                return
            }
            settingBgColor = true
            tdel?.setBackgroundColor(source: self, color: backgroundColor)
            settingBgColor = false
        }
    }
    
    // This tracks the requested cursor color or nil to use a view-default
    public var cursorColor: Color? = nil {
        didSet {
            if settingCursorColor {
                return
            }
            settingCursorColor = true
            tdel?.setCursorColor(source: self, color: cursorColor)
            settingCursorColor = false
        }
    }
    
    ///
    /// Represents the mouse operation mode that the terminal is currently using and higher level
    /// implementations should use the functions in this enumeration to determine what events to
    /// send
    public enum MouseMode {
        /// No mouse events are reported
        case off
        
        /// X10 Compatibility mode - only sends events in button press
        case x10
        
        /// VT200, also known as Normal Tracking Mode - sends both press and release events
        case vt200
        
        /// ButtonEventTracking - In addition to sending button press and release events, it sends motion events when the button is pressed
        case buttonEventTracking
        
        /// Sends button presses, button releases, and motion events regardless of the button state
        case anyEvent
        
        // Unsupported modes:
        // - vt200Highlight, this can deadlock the terminal
        // - declocator, rarely used
        
        /// Returns true if you should send a button press event (separate from release)
        func sendButtonPress () -> Bool
        {
            self == .vt200 || self == .buttonEventTracking || self == .anyEvent
        }
        
        /// Returns true if you should send the button release event
        func sendButtonRelease () -> Bool
        {
            self != .off
        }
        
        /// Returns true if you should send a motion event when a button is pressed
        func sendButtonTracking () -> Bool
        {
            self == .buttonEventTracking || self == .anyEvent
        }
        
        /// Returns true if you should send a motion event, regardless of button state
        public func sendMotionEvent () -> Bool
        {
            self == .anyEvent
        }
        
        /// Returns true if the modifiers should be encoded
        public func sendsModifiers() -> Bool {
            self == .vt200 || self == .buttonEventTracking || self == .anyEvent
        }
    }
    
    public private(set) var mouseMode: MouseMode = .off {
        didSet {
            tdel?.mouseModeChanged (source: self)
        }
    }

    // The next four variables determine whether setting/querying should be done using utf8 or latin1
    // and whether the values should be set or queried using hex digits, rather than actual byte streams
    var xtermTitleSetUtf = false
    var xtermTitleSetHex = false
    var xtermTitleQueryUtf = false
    var xtermTitleQueryHex = false
    
    var conformance: TerminalConformance = .vt500
    
    /**
     * Returns true if we should respect the left/right margins, which is based on the originMode and marginMode setting
     */
    func usingMargins() ->Bool
    {
        return originMode && marginMode
    }
    
    /// Returns the terminal dimensions 1-based values
    public func getDims () -> (cols: Int,rows: Int)
    {
        return (cols, rows)
    }
    
    public init (delegate: TerminalDelegate, options: TerminalOptions = TerminalOptions.default)
    {
        installedColors = Color.defaultInstalledColors
        defaultAnsiColors = Color.setupDefaultAnsiColors (initialColors: installedColors)
        ansiColors = defaultAnsiColors
        tdel = delegate
        self.options = options
        // This duplicates the setup above, but
        parser = EscapeSequenceParser ()
        normalBuffer = Buffer(cols: cols, rows: rows, tabStopWidth: tabStopWidth, scrollback: options.scrollback)
        normalBuffer.fillViewportRows()
        
        // The alt buffer should never have scrollback.
        // See http://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-The-Alternate-Screen-Buffer
        altBuffer = Buffer (cols: cols, rows: rows, tabStopWidth: tabStopWidth, scrollback: nil)
        buffer = normalBuffer

        cc = CC(send8bit: false)
        configureParser (parser)
        
        
        normalBuffer.scroll = scroll(isWrapped:)
        altBuffer.scroll = scroll(isWrapped:)

        setupTabStops()

        setup()
    }

    /// Installs the new colors as the default colors and recomputes the
    /// current and ansi palette.   This will not change the UI layer, for that it is better
    /// to call the `installColors` method on `TerminalView`, which will
    /// both call this method, and update the display appropriately.
    ///
    /// - Parameter colors: this should be an array of 16 values that correspond to the 16 ANSI colors,
    /// if the array does not contain 16 elements, it will not do anything
    public func installPalette (colors: [Color])
    {
        if colors.count != 16 {
            return
        }
        installedColors = colors
        defaultAnsiColors = Color.setupDefaultAnsiColors (initialColors: installedColors)
        ansiColors = defaultAnsiColors
    }
    
    /// Returns the CharData at the specified column and row from the visible portion of the buffer, these are zero-based
    ///
    /// - Parameter col: column to retrieve, starts at 0
    /// - Parameter row: row to retrieve, starts at 0
    /// - Returns: nil if the col or row are out of bounds, or the CharData contained in that cell otherwise
    ///
    public func getCharData (col: Int, row: Int) -> CharData?
    {
        if col < 0 || col >= cols {
            return nil
        }
        if let l = getLine (row: row) {
            return l [col]
        }
        return nil
    }

    /// Returns the contents of a line as a BufferLine, or nil if the requested line is out of range
    ///
    /// The line is counted  from start of scroll back, not what the terminal has visible right now.
    /// - Parameter row: the row to retrieve, relative to the scroll buffer, not the visible display
    /// - Returns: nil if the col or row are out of bounds, or the BufferLine  otherwise
    public func getLine (row: Int) -> BufferLine? {
        if row < 0 || row >= rows {
            return nil
        }
        return buffer.lines [row + buffer.yDisp]
    }

    /// Returns the contents of a line as a BufferLine counting from the begging of the scroll buffer.
    ///
    /// The line is counted  from start of scroll back, not what the terminal has visible right now.
    /// - Parameter row: the row to retrieve, relative to the scroll buffer, not the visible display
    /// - Returns: nil if the col or row are out of bounds, or the BufferLine  otherwise
    public func getScrollInvariantLine (row: Int) -> BufferLine? {
        if row < buffer.linesTop || row >= buffer.lines.count + buffer.linesTop {
            return nil
        }
        return buffer.lines [row-buffer.linesTop]
    }

    /// Returns the character at the specified column and row, these are zero-based
    /// - Parameter col: column to retrieve, starts at 0
    /// - Parameter row: row to retrieve, starts at 0
    /// - Returns: nil if the col or row are out of bounds, or the Character contained in that cell otherwise
    
    public func getCharacter (col: Int, row: Int) -> Character?
    {
        return getCharData(col: col, row: row)?.getCharacter()
    }
    
    public func resetNormalBuffer() {
        normalBuffer = Buffer(cols: cols, rows: rows, tabStopWidth: tabStopWidth, scrollback: options.scrollback)
        normalBuffer.scroll = scroll(isWrapped:)

        normalBuffer.fillViewportRows()
        normalBuffer.setupTabStops(tabStopWidth: tabStopWidth)
    }
    
    private func activateNormalBuffer(clearAlt: Bool) {
        if buffer === normalBuffer {
            return
        }
        normalBuffer.x = altBuffer.x
        normalBuffer.y = altBuffer.y
        
        // The alt buffer should always be cleared when we switch to the normal
        // buffer. This frees up memory since the alt buffer should always be new
        // when activated.
        
        if clearAlt {
            altBuffer.clear ()
        }
        buffer = normalBuffer
    }
    
    private func activateAltBuffer(fillAttr: Attribute?) {
        if buffer === altBuffer {
            return
        }
        altBuffer.x = normalBuffer.x
        altBuffer.y = normalBuffer.y
        
        // Since the alt buffer is always cleared when the normal buffer is
        // activated, we want to fill it when switching to it.
        
        altBuffer.fillViewportRows(attribute: fillAttr)
        buffer = altBuffer
    }
    
    func setupTabStops (index: Int = -1)
    {
        normalBuffer.setupTabStops(index: index, tabStopWidth: tabStopWidth)
        altBuffer.setupTabStops(index: index, tabStopWidth: tabStopWidth)
    }
    
    func resizeBuffers(newColumns: Int, newRows: Int) {
        // correct the savedY cursor to follow changes to y
        let dy = normalBuffer.savedY - normalBuffer.y
        normalBuffer.resize (newCols: newColumns, newRows: newRows)
        normalBuffer.savedY = normalBuffer.y + dy
        
        altBuffer.resize (newCols: newColumns, newRows: newRows)

    }
    public func setup (isReset: Bool = false)
    {
        // Sadly a duplicate of much of what lives in init() due to Swift not allowing me to
        // call this
        cols = max (options.cols, MINIMUM_COLS)
        rows = max (options.rows, MINIMUM_ROWS)
        
        if isReset {
            resetNormalBuffer()
            activateNormalBuffer(clearAlt: false)
        } else {
            normalBuffer.resize(newCols: cols, newRows: rows)
            altBuffer.resize(newCols: cols, newRows: rows)
        }
        cursorHidden = false
        
        // modes
        applicationKeypad = false
        applicationCursor = false
        originMode = false
        
        setMarginMode(false)
        setInsertMode(false)
        setWraparound(true)
        bracketedPasteMode = false
        
        // charset'
        charset = nil
        gcharset = 0
        gLevel = 0
        curAttr = CharData.defaultAttr
        
        mouseMode = .off
        
        buffer.scrollTop = 0
        buffer.scrollBottom = rows-1
        buffer.marginLeft = 0
        buffer.marginRight = cols-1
        
        cc.send8bit = false
        conformance = .vt500
        
        allow80To132 = true
        
        xtermTitleSetUtf = false
        xtermTitleQueryUtf = false
        
        xtermTitleSetHex = false
        xtermTitleQueryHex = false
        
        hyperLinkTracking = nil
        cursorBlink = false
        hostCurrentDirectory = nil
        lineFeedMode = options.convertEol
    }
    
    // DCS $ q Pt ST
    // DECRQSS (https://vt100.net/docs/vt510-rm/DECRQSS.html)
    //   Request Status String (DECRQSS), VT420 and up.
    // Response: DECRPSS (https://vt100.net/docs/vt510-rm/DECRPSS.html)
    class DECRQSS : DcsHandler {
        var data: [UInt8]
        unowned var terminal: Terminal

        public init (terminal: Terminal)
        {
            self.terminal = terminal
            data = []
        }

        func hook (collect: cstring, parameters: [Int],  flag: UInt8)
        {
            data = []
        }
        
        func put (data : ArraySlice<UInt8>)
        {
            for x in data {
                self.data.append(x)
            }
        }
        
        func unhook ()
        {
            let newData = String (bytes: data, encoding: .ascii)
            var ok = 1 // 0 means the request is valid according to docs, but tests expect 0?
            var result: String
            switch (newData) {
            case "\"q": // DECCSA - Set Character Attribute
                result = "\"q"
            case "\"p": // DECSCL - conformance level
                result = "65;1\"p"
            case "r": // DECSTBM - the top and bottom margins
                result = "\(terminal.buffer.scrollTop + 1);\(terminal.buffer.scrollBottom + 1)r"
            case "m": // SGR - the set graphic rendition
                // TODO: report real settings instead of 0m
                result = terminal.curAttr.toSgr ()
            case "s": // DECSLRM - the current left and right margins
                result = "\(terminal.buffer.marginLeft+1);\(terminal.buffer.marginRight+1)s"
            case " q": // DECSCUSR - the set cursor style
                // TODO this should send a number for the current cursor style 2 for block, 4 for underline and 6 for bar
                let style = "2" // block
                result = "\(style) q"
            default:
                ok = 0 // this means the request is not valid, report that to the host.
                // invalid: DCS 0 $ r Pt ST (xterm)
                terminal.log ("Unknown DCS + \(newData!)")
                // Do not report 'newData', because it can be exploited
                // see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=510030
                result = ""

            }
            terminal.sendResponse (terminal.cc.DCS, "\(ok)$r\(result)", terminal.cc.ST)
        }
    }

    // Configures the EscapeSequenceParser
    func configureParser (_ parser: EscapeSequenceParser)
    {
        parser.csiHandlerFallback = { [unowned self] (pars: [Int], collect: cstring, code: UInt8) -> () in
            let ch = Character(UnicodeScalar(code))
            self.log ("Unknown CSI Code (collect=\(collect) code=\(ch) pars=\(pars))")
        }
        parser.escHandlerFallback = { [unowned self] (txt: cstring, flag: UInt8) in
            self.log ("Unknown ESC Code: ESC + \(Character(Unicode.Scalar (flag))) txt=\(txt)")
        }
        parser.executeHandlerFallback = { [unowned self] in
            self.log ("Unknown EXECUTE code")
        }
        parser.oscHandlerFallback = { [unowned self] code, data in
            self.log ("Unknown OSC code: \(code)")
        }
        parser.printHandler = { [unowned self] slice in handlePrint (slice) }
        parser.printStateReset = { [unowned self] in printStateReset() }
        
        // CSI handler
        parser.csiHandlers [UInt8 (ascii: "@")] = { [unowned self] pars, collect in cmdInsertChars (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "A")] = { [unowned self] pars, collect in cmdCursorUp (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "B")] = { [unowned self] pars, collect in cmdCursorDown (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "C")] = { [unowned self] pars, collect in cmdCursorForward (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "D")] = { [unowned self] pars, collect in cmdCursorBackward (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "E")] = { [unowned self] pars, collect in cmdCursorNextLine (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "F")] = { [unowned self] pars, collect in cmdCursorPrecedingLine (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "G")] = { [unowned self] pars, collect in cmdCursorCharAbsolute (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "H")] = { [unowned self] pars, collect in cmdCursorPosition (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "I")] = { [unowned self] pars, collect in cmdCursorForwardTab (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "J")] = { [unowned self] pars, collect in cmdEraseInDisplay (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "K")] = { [unowned self] pars, collect in cmdEraseInLine (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "L")] = { [unowned self] pars, collect in cmdInsertLines (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "M")] = { [unowned self] pars, collect in cmdDeleteLines (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "P")] = { [unowned self] pars, collect in cmdDeleteChars (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "S")] = { [unowned self] pars, collect in cmdScrollUp (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "T")] = { [unowned self] pars, collect in csiT (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "X")] = { [unowned self] pars, collect in cmdEraseChars (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "Z")] = { [unowned self] pars, collect in cmdCursorBackwardTab (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "`")] = { [unowned self] pars, collect in cmdCharPosAbsolute (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "a")] = { [unowned self] pars, collect in cmdHPositionRelative (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "b")] = { [unowned self] pars, collect in cmdRepeatPrecedingCharacter (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "c")] = { [unowned self] pars, collect in cmdSendDeviceAttributes (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "d")] = { [unowned self] pars, collect in cmdLinePosAbsolute (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "e")] = { [unowned self] pars, collect in cmdVPositionRelative (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "f")] = { [unowned self] pars, collect in cmdHVPosition (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "g")] = { [unowned self] pars, collect in cmdTabClear (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "h")] = { [unowned self] pars, collect in cmdSetMode (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "l")] = { [unowned self] pars, collect in cmdResetMode (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "m")] = { [unowned self] pars, collect in cmdCharAttributes (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "n")] = { [unowned self] pars, collect in cmdDeviceStatus (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "p")] = { [unowned self] pars, collect in csiPHandler (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "q")] = { [unowned self] pars, collect in cmdSetCursorStyle (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "r")] = { [unowned self] pars, collect in cmdSetScrollRegion (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "s")] = { [unowned self] args, cstring in
            // "CSI s" is overloaded, can mean save cursor, but also set the margins with DECSLRM
            if self.marginMode {
                self.cmdSetMargins (args, cstring)
            } else {
                self.cmdSaveCursor (args, cstring)
            }
        }
        parser.csiHandlers [UInt8 (ascii: "t")] = { [unowned self] pars, collect in csit (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "u")] = { [unowned self] pars, collect in cmdRestoreCursor (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "v")] = { [unowned self] pars, collect in csiCopyRectangularArea (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "x")] = { [unowned self] pars, collect in csiX (pars, collect) } /* x DECFRA - could be overloaded */
        parser.csiHandlers [UInt8 (ascii: "y")] = { [unowned self] pars, collect in cmdDECRQCRA (pars, collect) } /* y - Checksum Region */
        parser.csiHandlers [UInt8 (ascii: "z")] = { [unowned self] pars, collect in csiZ (pars, collect) } /* DECERA */
        parser.csiHandlers [UInt8 (ascii: "{")] = { [unowned self] pars, collect in csiOpenBrace (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "}")] = { [unowned self] pars, collect in csiCloseBrace (pars, collect) }
        parser.csiHandlers [UInt8 (ascii: "~")] = { [unowned self] pars, collect in cmdDeleteColumns (pars, collect) }

        parser.executeHandlers [7]  = { [unowned self] in self.tdel?.bell (source: self) }
        parser.executeHandlers [10] = { [unowned self] in cmdLineFeed () }
        parser.executeHandlers [11] = { [unowned self] in cmdLineFeedBasic () }  // VT Vertical Tab - ignores auto-new-line behavior in ConvertEOL
        parser.executeHandlers [12] = { [unowned self] in cmdLineFeedBasic () }
        parser.executeHandlers [13] = { [unowned self] in cmdCarriageReturn () }
        parser.executeHandlers [8]  = { [unowned self] in cmdBackspace () }
        parser.executeHandlers [9]  = { [unowned self] in cmdTab () }
        parser.executeHandlers [14] = { [unowned self] in cmdShiftOut () }
        parser.executeHandlers [15] = { [unowned self] in cmdShiftIn () }
        
        parser.executeHandlers [0x84] = { [unowned self] in cmdIndex () }
        parser.executeHandlers [0x85] = { [unowned self] in cmdNextLine () }
        parser.executeHandlers [0x88] = {  [unowned self] in cmdTabSet () }

        //
        // OSC handler - ESC ]
        //
        //   0 - icon name + title
        parser.oscHandlers [0] = { [unowned self] data in self.setTitle(text: String (bytes: data, encoding: .utf8) ?? "")}
        //   1 - icon name
        parser.oscHandlers [1] = { [unowned self] data in self.setIconTitle(text: String (bytes: data, encoding: .utf8) ?? "") }
        //   2 - title
        parser.oscHandlers [2] = { [unowned self] data in self.setTitle(text: String (bytes: data, encoding: .utf8) ?? "")}
        //   3 - set property X in the form "prop=value"
        //   4 - Change Color Number()
        parser.oscHandlers [4] = { [unowned self] data in oscChangeOrQueryColorIndex (data) }
        
        //   5 - Change Special Color Number
        //   6 - Enable/disable Special Color Number c

        //   6 - current document:
        parser.oscHandlers [6] = { [unowned self] data in oscSetCurrentDocument (data) }

        //   7 - current directory? (not in xterm spec, see https://gitlab.com/gnachman/iterm2/issues/3939)
        parser.oscHandlers [7] = { [unowned self] data in oscSetCurrentDirectory (data) }
        
        parser.oscHandlers [8] = { [unowned self] data in oscHyperlink (data) }
        //  10 - Change VT100 text foreground color to Pt.
        parser.oscHandlers [10] = { [unowned self] data in oscSetColors (data, startAt: 0) }
        //  11 - Change VT100 text background color to Pt.
        parser.oscHandlers [11] = { [unowned self] data in oscSetColors (data, startAt: 1) }
        //  12 - Change text cursor color to Pt.
        parser.oscHandlers [12] = { [unowned self] data in oscSetColors (data, startAt: 2) }
        
        //  13 - Change mouse foreground color to Pt.
        //  14 - Change mouse background color to Pt.
        //  15 - Change Tektronix foreground color to Pt.
        //  16 - Change Tektronix background color to Pt.
        //  17 - Change highlight background color to Pt.
        //  18 - Change Tektronix cursor color to Pt.
        //  19 - Change highlight foreground color to Pt.
        //  46 - Change Log File to Pt.
        //  50 - Set Font to Pt.
        //  51 - reserved for Emacs shell.
        //  52 - Clipboard operations
        parser.oscHandlers [52] = { [unowned self] data in oscClipboard (data) }
        // 104 ; c - Reset Color Number c.
        parser.oscHandlers [104] = { [unowned self] data in oscResetColor (data) }
        
        // 105 ; c - Reset Special Color Number c.
        // 106 ; c; f - Enable/disable Special Color Number c.
        // 110 - Reset VT100 text foreground color.
        // 111 - Reset VT100 text background color.
        parser.oscHandlers[112] = { [unowned self] data in tdel?.setCursorColor(source: self, color: nil)}
        // 113 - Reset mouse foreground color.
        // 114 - Reset mouse background color.
        // 115 - Reset Tektronix foreground color.
        // 116 - Reset Tektronix background color.
        parser.oscHandlers [777] = { [unowned self] data in oscNotification (data) }
        parser.oscHandlers [1337] = { [unowned self] data in osciTerm2 (data) }

        //
        // ESC handlers
        //
        parser.setEscHandler("6",   { [unowned self] collect, flag in self.columnIndex (back: true) })
        parser.setEscHandler ("7",  { [unowned self] collect, flag in self.cmdSaveCursor ([], []) })
        parser.setEscHandler ("8",  { [unowned self] collect, flag in self.cmdRestoreCursor ([], []) })
        parser.setEscHandler ("9",  { [unowned self] collect, flag in self.columnIndex(back: false) })
        parser.setEscHandler ("D",  { [unowned self] collect, flag in self.cmdIndex() })
        parser.setEscHandler ("E",  { [unowned self] collect, flag in self.cmdNextLine () })
        parser.setEscHandler ("H",  { [unowned self] collect, flag in self.cmdTabSet ()})
        parser.setEscHandler ("M",  { [unowned self] collect, flag in self.reverseIndex() })
        parser.setEscHandler ("=",  { [unowned self] collect, flag in self.cmdKeypadApplicationMode ()})
        parser.setEscHandler (">",  { [unowned self] collect, flag in self.cmdKeypadNumericMode ()})
        parser.setEscHandler ("c",  { [unowned self] collect, flag in self.cmdReset () })
        parser.setEscHandler ("n",  { [unowned self] collect, flag in self.setgLevel (2) })
        parser.setEscHandler ("o",  { [unowned self] collect, flag in self.setgLevel (3) })
        parser.setEscHandler ("|",  { [unowned self] collect, flag in self.setgLevel (3) })
        parser.setEscHandler ("}",  { [unowned self] collect, flag in self.setgLevel (2) })
        parser.setEscHandler ("~",  { [unowned self] collect, flag in self.setgLevel (1) })
        parser.setEscHandler ("%@", { [unowned self] collect, flag in self.cmdSelectDefaultCharset () })
        parser.setEscHandler ("%G", { [unowned self] collect, flag in self.cmdSelectDefaultCharset () })
        parser.setEscHandler ("#3", { [unowned self] collect, flag in self.cmdSetDoubleHeightTop() })
        parser.setEscHandler ("#4", { [unowned self] collect, flag in self.cmdSetDoubleHeightBottom() })
        parser.setEscHandler ("#5", { [unowned self] collect, flag in self.cmdSingleWidthSingleHeight() })
        parser.setEscHandler ("#6", { [unowned self] collect, flag in self.cmdDoubleWidthSingleHeight () })
        parser.setEscHandler ("#8", { [unowned self] collect, flag in self.cmdScreenAlignmentPattern () })
        parser.setEscHandler (" G") { [unowned self] collect, flag in self.cmdSet8BitControls () }
        parser.setEscHandler (" F") { [unowned self] collect, flag in self.cmdSet7BitControls () }
        
        for bflag in CharSets.all.keys {
            let flag = String (UnicodeScalar (bflag))
            
            parser.setEscHandler ("(" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: "(")] + [f]) })
            parser.setEscHandler (")" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: ")")] + [f]) })
            parser.setEscHandler ("*" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: "*")] + [f]) })
            parser.setEscHandler ("+" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: "+")] + [f]) })
            parser.setEscHandler ("-" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: "-")] + [f]) })
            parser.setEscHandler ("." + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: ".")] + [f]) })
            parser.setEscHandler ("/" + flag, { [unowned self] code, f in self.selectCharset ([UInt8 (ascii: "/")] + [f]) })
        }

        // Error handler
        parser.errorHandler = { [unowned self] state in
            self.log ("Parsing error, state: \(state)")
            return state
        }

        // DCS Handler
        parser.setDcsHandler ("$q", DECRQSS (terminal: self))
        parser.setDcsHandler ("q", SixelDcsHandler (terminal: self))
        parser.dscHandlerFallback = { code, parameters in }
    }
    
    /// This allows users of the terminal to register a handler for an OSC code.
    /// - Parameters:
    ///  - code: the code for the OSC handler to register, no checks are made that this overrides an existing handler
    ///  - handler: the code to invoke when the OSC handler is received.
    public func registerOscHandler (code: Int, handler: @escaping (ArraySlice<UInt8>) -> ())
    {
        parser.oscHandlers [code] = handler
    }
    
    func cmdSet8BitControls ()
    {
        cc.send8bit = true
    }

    func cmdSet7BitControls ()
    {
        cc.send8bit = false
    }

    func emitScroll (_ x: Int)
    {
        // In the original code, it is mediocre accessibility, so likely will remove this
    }
    
    func emitChar (_ ch: Character)
    {
        // In the original code, it is mediocre accessibility, so likely will remove this
    }

    //
    // Because data might not be complete, we need to put back data that we read to process on
    // a future read.  To prepare for reading, on every call to parse, the prepare method is
    // given the new ArraySlice to read from.
    //
    // the `hasNext` describes whether there is more data left on the buffer, and `bytesLeft`
    // returnes the number of bytes left.   The `getNext` method fetches either the next
    // value from the putback buffer, or when it is empty, it returns it from the buffer that
    // was passed during prepare.
    //
    // Additionally, the terminal parser needs to reset the parser state on demand, and
    // that is surfaced via reset
    //
    private struct ReadingBuffer {
        var putbackBuffer: [UInt8] = []
        var rest:ArraySlice<UInt8> = [][...]
        var idx = 0
        var count:Int = 0
        
        // Invoke this method at the beginning of parse
        mutating func prepare (_ data: ArraySlice<UInt8>)
        {
            assert (rest.count == 0)
            rest = data
            count = putbackBuffer.count + data.count
            idx = 0
        }
        
        func hasNext () -> Bool {
            idx < count
        }
        
        func bytesLeft () -> Int
        {
            count-idx
        }
        
        mutating func getNext () -> UInt8
        {
            if idx < putbackBuffer.count {
                let v = putbackBuffer [idx]
                idx += 1
                return v
            }
            let v = rest [idx-putbackBuffer.count+rest.startIndex]
            idx += 1
            return v
        }
        
        // Puts back the code, and everything that was pending
        mutating func putback (_ code: UInt8)
        {
            var newPutback: [UInt8] = [code]
            let left = bytesLeft()
            for _ in 0..<left {
                newPutback.append (getNext ())
            }
            putbackBuffer = newPutback
            rest = [][...]
        }
        
        mutating func done  ()
        {
            if idx < putbackBuffer.count {
                putbackBuffer.removeFirst(idx)
            } else {
                putbackBuffer = []
            }
            rest = [][...]
        }
        
        mutating func reset ()
        {
            putbackBuffer = []
            idx = 0
        }
    }
    
    private var readingBuffer = ReadingBuffer ()
    
    func printStateReset ()
    {
        readingBuffer.reset ()
    }
    
    // TODO: was this unused
    var lastBufferCol: Int = 0
    
    func handlePrint (_ data: ArraySlice<UInt8>)
    {
        let buffer = self.buffer
        readingBuffer.prepare(data)

        updateRange (buffer.y)
        while readingBuffer.hasNext() {
            var ch: Character = " "
            var chWidth: Int = 0
            let code = readingBuffer.getNext()
            
            let n = UnicodeUtil.expectedSizeFromFirstByte(code)

            if n == -1 || n == 1 {
                // n == -1 means an Invalid UTF-8 sequence, client sent us some junk, happens if we run
                // with the wrong locale set for example if LANG=en, still we handle it here

                // get charset replacement character
                // charset are only defined for ASCII, therefore we only
                // search for an replacement char if code < 127
                if code < 127 && charset != nil {
                    
                    // Notice that the charset mapping can contain the dutch unicode sequence for "ij",
                    // so it is not a simple byte, it is a Character
                    if let str = charset! [UInt8 (code)] {
                        ch = str.first!
                        
                        // Every single mapping in the charset only takes one slot
                        chWidth = 1
                        let charData = CharData (attribute: curAttr, char: ch, size: Int8 (chWidth))
                        buffer.insertCharacter(charData)
                        continue
                    }
                }
                
                let rune = UnicodeScalar (code)
                chWidth = UnicodeUtil.columnWidth(rune: rune)
                let charData = CharData (attribute: curAttr, scalar: rune, size: Int8 (chWidth))
                buffer.insertCharacter(charData)
                continue
            } else if readingBuffer.bytesLeft() >= (n-1) {
                var x : [UInt8] = [code]
                for _ in 1..<n {
                    x.append (readingBuffer.getNext())
                }
                x.append(0)
                x.withUnsafeBytes { ptr in
                    let unsafeBound = ptr.bindMemory(to: UInt8.self)
                    let unsafePointer = unsafeBound.baseAddress!
                    
                    let s = String (cString: unsafePointer)
                    ch = s.first ?? Character (" ")

                    // Now the challenge is that we have a character, not a rune, and we want to compute
                    // the width of it.
                    if ch.unicodeScalars.count == 1 {
                        chWidth = UnicodeUtil.columnWidth(rune: ch.unicodeScalars.first!)
                    } else {
                        chWidth = 0
                        for scalar in ch.unicodeScalars {
                            chWidth = max (chWidth, UnicodeUtil.columnWidth(rune: scalar))
                        }
                    }
                }
            } else {
                readingBuffer.putback (code)
                return
            }

            if let firstScalar = ch.unicodeScalars.first {
                // If this is a Unicode combining character
                if firstScalar.properties.canonicalCombiningClass != .notReordered {
                    // Determine if the last time we poked at a character is still valid
                    let last = buffer.lastBufferStorage
                    if last.cols == cols && last.rows == rows {
                        // Fetch the old character, and attempt to combine it:
                        let existingLine = buffer.lines [last.y]
                        let lastx = last.x >= cols ? cols-1 : last.x
                        var cd = existingLine [lastx]
                        
                        // Attemp the combination
                        let newStr = String ([cd.getCharacter (), ch])
                        
                        // If the resulting string is 1 grapheme cluster, then it combined properly
                        if newStr.count == 1 {
                            if let newCh = newStr.first {
                                cd.setValue(char: newCh, size: Int32 (cd.width))
                                existingLine [lastx] = cd
                                updateRange (last.y)
                                continue
                            }
                        }
                    }
                }
            }
            // The accessibility stack might not need this
            //let screenReaderMode = options.screenReaderMode
            //if screenReaderMode {
            //    emitChar (ch)
            //}
            if ch != "\u{200d}" {
                let charData = CharData (attribute: curAttr, char: ch, size: Int8 (chWidth))
                buffer.insertCharacter(charData)
            }
        }
        updateRange (buffer.y)
        readingBuffer.done ()
    }
    
    // Inserts the specified character with the computed width into the next cell, following
    // the rules for wrapping around, scrolling and overflow expected in the terminal.
    func insertCharacter (_ charData: CharData) {
        // TODO, make this a direct call. no need to pproxy here
        buffer.insertCharacter(
            charData)
    }
    
//    func insertCharacter2(_ charData: CharData) {
//        let buffer = self.buffer
//        var chWidth = Int (charData.width)
//
//        let right = marginMode ? buffer.marginRight : cols - 1
//        // goto next line if ch would overflow
//        // TODO: needs a global min terminal width of 2
//        // FIXME: additionally ensure chWidth fits into a line
//        //   -->  maybe forbid cols<xy at higher level as it would
//        //        introduce a bad runtime penalty here
//        if buffer.x + chWidth - 1 > right {
//            // autowrap - DECAWM
//            // automatically wraps to the beginning of the next line
//            if wraparound {
//                buffer.x = marginMode ? buffer.marginLeft : 0
//
//                if buffer.y >= buffer.scrollBottom {
//                    scroll (isWrapped: true)
//                } else {
//                    // The line already exists (eg. the initial viewport), mark it as a
//                    // wrapped line
//                    buffer.y += 1
//                    buffer.lines [buffer.y].isWrapped = true
//                }
//                // row changed, get it again
//            } else {
//                if (chWidth == 2) {
//                    // FIXME: check for xterm behavior
//                    // What to do here? We got a wide char that does not fit into last cell
//                    return
//                }
//                // FIXME: Do we have to set buffer.x to cols - 1, if not wrapping?
//                buffer.x = right
//            }
//        } 
//        let bufferRow = buffer.lines [buffer.y + buffer.yBase]
//
//        var empty = CharData.Null
//        empty.attribute = curAttr
//        // insert mode: move characters to right
//        if insertMode {
//            // right shift cells according to the width
//            bufferRow.insertCells (pos: buffer.x, n: chWidth, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: empty)
//            // test last cell - since the last cell has only room for
//            // a halfwidth char any fullwidth shifted there is lost
//            // and will be set to eraseChar
//            let lastCell = bufferRow [cols - 1]
//            if lastCell.width == 2 {
//                bufferRow [cols - 1] = empty
//            }
//        }
//
//        // write current char to buffer and advance cursor
//        //TODO: lastBufferStorage = (buffer, buffer.y + buffer.yBase, buffer.x, cols, rows)
//        if buffer.x >= cols {
//            buffer.x = cols-1
//        }
//        bufferRow [buffer.x] = charData
//        buffer.x += 1
//
//        // fullwidth char - also set next cell to placeholder stub and advance cursor
//        // for graphemes bigger than fullwidth we can simply loop to zero
//        // we already made sure above, that buffer.x + chWidth will not overflow right
//        if chWidth > 0 {
//            chWidth -= 1
//            while chWidth != 0 && buffer.x < buffer.cols {
//                bufferRow [buffer.x] = empty
//                buffer.x += 1
//                chWidth -= 1
//            }
//        }
//    }

    func cmdLineFeed ()
    {
        cmdLineFeedBasic ()
    }
    
    func cmdLineFeedBasic ()
    {
        let buffer = self.buffer
        let by = buffer.y
        
        let canScroll = buffer.x >= buffer.marginLeft && buffer.x <= buffer.marginRight
        
        if by == buffer.scrollBottom {
            if canScroll {
                scroll(isWrapped: false)
            }
        } else if by == rows - 1 {
        } else {
                buffer.y = by + 1
        }
        
        // If the end of the line is hit, prevent this action from wrapping around to the next line.
        if buffer.x >= cols {
            buffer.x -= 1
        }
        
        // This event is emitted whenever the terminal outputs a LF or NL.
        emitLineFeed()
        if lineFeedMode {
            buffer.x = usingMargins() ? buffer.marginLeft : 0
        }
    }
    
    //
    // Backspace handler (Control-h)
    //
    func cmdBackspace ()
    {
        let buffer = self.buffer
        restrictCursor(!reverseWraparound)
        
        let left = marginMode ? buffer.marginLeft : 0
        let right = marginMode ? buffer.marginRight : buffer.cols-1

        if buffer.x > left {
            buffer.x -= 1
        } else if reverseWraparound {
            if buffer.x <= left {
                if buffer.y > buffer.scrollTop && buffer.y <= buffer.scrollBottom && (buffer.lines [buffer.y + buffer.yBase].isWrapped || marginMode) {
                    if !marginMode {
                        buffer.lines [buffer.y + buffer.yBase].isWrapped = false
                    }
                    
                    buffer.y -= 1
                    buffer.x = right
                // TODO: find actual last cell based on width used
                } else if buffer.y == buffer.scrollTop {
                    buffer.x = right
                    buffer.y = buffer.scrollBottom
                } else if buffer.y > 0 {
                    buffer.x = right
                    buffer.y -= 1
                }
            }
        } else {
            if buffer.x < left && buffer.x > 0 {
                // This compensates for the scenario where backspace is supposed to move one step
                // backwards if the "x" position is behind the left margin.
                // Test BS_MovesLeftWhenLeftOfLeftMargin
                buffer.x -= 1
            } else if buffer.x > left {
                // If we have not reached the limit, we can go back, otherwise stop at the margin
                // Test BS_StopsAtLeftMargin
                buffer.x -= 1
            
            }
        }
    }
    
    func cmdCarriageReturn ()
    {
        let buffer = self.buffer
        if marginMode {
            if buffer.x < buffer.marginLeft {
                buffer.x = 0
            } else {
                buffer.x = buffer.marginLeft
            }
        } else {
            buffer.x = 0
        }
    }
    
    //
    // Horizontal tab (control-i)
    //
    func cmdTab ()
    {
        buffer.x = buffer.nextTabStop (marginMode: marginMode)
    }

    // SO
    // ShiftOut (Control-N) Switch to alternate character set.  This invokes the G1 character set
    func cmdShiftOut ()
    {
        setgLevel (1)
    }
    
    // SI
    // ShiftIn (Control-O) Switch to standard character set.  This invokes the G0 character set
    func cmdShiftIn ()
    {
        setgLevel(0)
    }
    
    // Operating System Commands (OSC)
    
    func resetAllColors ()
    {
        ansiColors = defaultAnsiColors
        tdel?.colorChanged (source: self, idx: nil)
    }
    
    func resetColor (_ number: Int)
    {
        if number > 255 {
            return
        }
        ansiColors [number] = defaultAnsiColors [number]
        tdel?.colorChanged(source: self, idx: number)
    }
    
    func oscResetColor (_ data: ArraySlice<UInt8>)
    {
        if data == [] {
            resetAllColors()
        } else {
            if let param = String (bytes: data, encoding: .ascii) {
                let colors = param.split(separator: ";")
                for color in colors {
                    resetColor (Int (color) ?? 0)
                }
            }
        }
    }
    
    // Implements OSC 7 ; URL which records the current working directory
    func oscSetCurrentDirectory (_ data: ArraySlice<UInt8>)
    {
        if !(tdel?.isProcessTrusted(source: self) ?? false) {
            return
        }
        var s = String (bytes:data, encoding: .utf8)
        if s == nil {
            s = String (bytes:data, encoding: .ascii)
        }
        if let txt = s {
            hostCurrentDirectory = txt
            tdel?.hostCurrentDirectoryUpdated (source: self)
        }
    }
    
    // Implements OSC 6 ; URL which records the current document
    func oscSetCurrentDocument (_ data: ArraySlice<UInt8>)
    {
        if !(tdel?.isProcessTrusted(source: self) ?? false) {
            return
        }
        var s = String (bytes:data, encoding: .utf8)
        if s == nil {
            s = String (bytes:data, encoding: .ascii)
        }
        if let txt = s {
            hostCurrentDocument = txt
            tdel?.hostCurrentDocumentUpdated (source: self)
        }
    }

    var hyperLinkTracking: (start: Position, payload: String)? = nil
    
    func oscHyperlink (_ data: ArraySlice<UInt8>)
    {
        let buffer = self.buffer
        if data.count == 1 && data [data.startIndex] == UInt8 (ascii: ";") {
            // We only had the terminator, so we can close ";"
            if let hlt = hyperLinkTracking {
                let str = hlt.payload
                if let urlToken = TinyAtom.lookup (value: str) {
                    //print ("Setting the text from \(hlt.start) to \(buffer.x) on line \(buffer.y+buffer.yBase) to \(str)")
                    
                    // Between the time the flag was set, and now `y` might have changed negatively,
                    // in that case, we do not flag any sequence as a hyperlink
                    if hlt.start.row <= buffer.y+buffer.yBase {
                        for y in hlt.start.row...(buffer.y+buffer.yBase) {
                            let line = buffer.lines [y]
                            let startCol = y == hlt.start.row ? min (hlt.start.col, cols-1) : 0
                            let endCol = y == buffer.y ? min (buffer.x, cols-1) : (marginMode ? buffer.marginRight : cols-1)
                            if endCol > startCol {
                                for x in startCol...endCol {
                                    var cd = line [x]
                                    cd.setPayload(atom: urlToken)
                                    line [x] = cd
                                }
                            }
                        }
                    }
                }
            }
            hyperLinkTracking = nil
        } else {
            hyperLinkTracking = (start: Position(col: buffer.x, row: buffer.y+buffer.yBase), payload: String (bytes:data, encoding: .ascii) ?? "")
        }
    }
    
    // Copy to clipboard with sequence on the form:
    //    ESC ] 52 ; c ; [base64 data] \a
    // where c is for copy and the only thing supported.
    func oscClipboard (_ data: ArraySlice<UInt8>) {
        // we require data to start with c; followed by base64 content
        guard data.count >= 2,
              data[data.startIndex] == UInt8(ascii: "c"),
              data[data.startIndex+1] == UInt8(ascii: ";") else {
            return
        }
        
        let base64 = Data(data[(data.startIndex+2)...])
        guard let content = Data(base64Encoded: base64) else {
            return
        }
        
        tdel?.clipboardCopy(source: self, content: content)
    }
    
    // Notifications:
    //    ESC ] 777 ; notify ; [title] ; [body] \a
    func oscNotification(_ data: ArraySlice<UInt8>) {
        guard let text = String(bytes: data, encoding: .utf8) else {
            return
        }
        
        let parts = text.components(separatedBy: ";")
        guard parts.count >= 3,
              parts[0] == "notify" else {
            return
        }
        
        let title = parts[1]
        let body = parts[2...].joined(separator: ";")
        tdel?.notify(source: self, title: title, body: body)
    }

    // OSC 1337 is used by iTerm2 for imgcat and other things:
    //  https://iterm2.com/documentation-images.html
    // ESC ] 1337 ; key = value ^G
    //
    // Options
    // ESC ] 1337 ; File = [arguments] : base-64 encoded file contents ^G
    //
    func osciTerm2 (_ data: ArraySlice<UInt8>) {
        // Parses the key-value pairs separated by ";"
        func parseKeyValues (_ data: ArraySlice<UInt8>) -> [String:String] {
            var kv: [String:String] = [:]
            var current = data.startIndex
            repeat {
                let next = data [current..<data.endIndex].firstIndex(where: { b in b == UInt8 (ascii: ";")}) ?? data.endIndex
                guard let equalIdx = data [current..<next].firstIndex(where: { b in b == UInt8 (ascii: "=")}) else {
                    break
                }
                guard let key = String (bytes: data[current..<equalIdx], encoding: .utf8) else {
                    break
                }
                guard let value = String (bytes: data[equalIdx+1..<next], encoding: .utf8) else {
                    break
                }
                kv [key] = value
                current = next == data.endIndex ? next : next+1
            } while current < data.endIndex
            return kv
        }
        
        /// Parses the dimension specification ("auto", "N%", "Npx" or "N") and returns the enum value for it
        /// puts some artificial limits, to prevent bloat or attacks
        func parseDimension(_ kv: [String:String], key: String) -> ImageSizeRequest {
            let artificialDimensionSizeLimit = 1024*4
            let artificialColumnLimit = 200
            
            guard let v = kv [key] else {
                return .auto
            }
            if v == "auto" { return .auto }
            if v.hasSuffix ("%") {
                if let n = Int (v.dropLast(1)), n > 0, n <= 100 { return .percent (n) }
                return .auto
            }
            if v.hasSuffix("px") {
                if let n = Int (v.dropLast(2)), n > 0, n < artificialDimensionSizeLimit { return .pixels (n) }
                return .auto
            }
            if let n = Int (v), n > 0, n < artificialColumnLimit { return .cells(n) }
            return .auto
        }
        
        guard let equalIdx = data.firstIndex (where: { b in b == UInt8(ascii: "=") }) else {
            return
        }
        
        guard let key = String(bytes: data[data.startIndex..<equalIdx], encoding: .utf8) else {
            return
        }
        switch key {
        case "File":
            guard let colonIdx = data [equalIdx...].firstIndex(where: { b in b == UInt8 (ascii: ":")}) else {
                return
            }
            let kv = parseKeyValues (data [equalIdx+1..<colonIdx])
            // inline == 1 means to display the image inline, the option == 0 downloads the provided file
            // into the file system.   In that case, we let the
            // user of the library handle this via the iTermContent
            // delegate
            if kv["inline"] != "1" {
                break
            }
            
            guard let imgData = Data(base64Encoded: Data(data [colonIdx+1..<data.endIndex])) else {
                return
            }
            let width = parseDimension (kv, key: "width")
            let height = parseDimension (kv, key: "height")

            tdel?.createImage(source: self, data: imgData, width: width, height: height, preserveAspectRatio: (kv ["preserveAspectRatio"] ?? "1" ) == "1")
            return
        default:
            break
        }
        
        tdel?.iTermContent(source: self, content: data)
    }
    
    // OSC 4
    func oscChangeOrQueryColorIndex (_ data: ArraySlice<UInt8>)
    {
        var parsePos = data.startIndex
        while parsePos <= data.endIndex {
            guard let p = data [parsePos...].firstIndex(of: UInt8 (ascii: ";")) else {
                return
            }
            let color = EscapeSequenceParser.parseInt(data [parsePos..<p])
            guard color < 256 else {
                return
            }
        
            // If the request is a query, reply with the current color definition
            if p+1 < data.endIndex && data [p+1] == UInt8 (ascii: "?") {
                sendResponse (cc.OSC, "4;\(color);\(ansiColors [color].formatAsXcolor())", cc.ST)
                parsePos = p+2
                if parsePos < data.endIndex && data [parsePos] == UInt8(ascii: ";"){
                    parsePos += 1
                }
                continue
            }
    
            //let str = String (bytes:data, encoding: .ascii) ?? ""
            //print ("Parsing color definition \(str)")

            parsePos = p + 1
        
            let end = data [parsePos...].firstIndex(of: UInt8(ascii: ";")) ?? data.endIndex
            
            if let newColor = Color.parseColor (data [parsePos..<end]) {
                ansiColors [color] = newColor
                tdel?.colorChanged (source: self, idx: color)
            }
            parsePos = end+1
        }
        
        //log ("Attempt to set the text Foreground color \(str)")
    }
    
    func reportColor (oscCode: Int, color: Color) {
        sendResponse(cc.OSC, "\(oscCode);\(color.formatAsXcolor ())", cc.ST)
    }
    
    // This handles both setting the foreground, but spill into background and cursor color
    // if more parameters are provided (ie, sending OSC 10 with #ffffff,#000000,#ff0000
    // sets the foreground to #ffffff, background to #000000 and cursor to ff0000
    //
    // - Parameter startAt: describes which of the colors is the first to try,
    // startAt = 0 is foreground, startAt = 1 is background, startAt = 2 is
    // the cursor Color
    func oscSetColors (_ data: ArraySlice<UInt8>, startAt: Int)
    {
        let groups = data.split(separator: UInt8 (ascii: ";"))
        var next = startAt
        while next < groups.count {
            defer { next += 1 }
            let text = groups [next]
            
            if text.first == UInt8 (ascii: "?") {
                switch next {
                case 0:
                    reportColor (oscCode: 10, color: foregroundColor)
                case 1:
                    reportColor (oscCode: 11, color: backgroundColor)
                case 2:
                    reportColor (oscCode: 11, color: cursorColor ?? foregroundColor)
                default:
                    break
                }
                
                continue
            }

            guard let color = Color.parseColor(text) else {
                continue
            }
            switch next {
            case 0:
                foregroundColor = color
                tdel?.setForegroundColor(source: self, color: color)
            case 1:
                backgroundColor = color
                tdel?.setBackgroundColor(source: self, color: color)
            case 2:
                cursorColor = color
                tdel?.setCursorColor(source: self, color: color)
                break
            default:
                break
            }
        }
    }

    func oscSetTextBackground (_ data: ArraySlice<UInt8>)
    {
        if data.first == UInt8 (ascii: "?") {
            reportColor (oscCode: 11, color: backgroundColor)
            return
        }

        if let background = Color.parseColor(data) {
            backgroundColor = background
            tdel?.setBackgroundColor(source: self, color: background)
        }
    }

    func oscSetCursorColor (_ data: ArraySlice<UInt8>)
    {
        if let cursorColor = Color.parseColor(data) {
            self.cursorColor = cursorColor
            tdel?.setCursorColor(source: self, color: cursorColor)
        }
    }

    //
    // ESC E
    // C1.NEL
    //   DEC mnemonic: NEL (https://vt100.net/docs/vt510-rm/NEL)
    //   Moves cursor to first position on next line.
    //
    func cmdNextLine ()
    {
        buffer.x = usingMargins () ? buffer.marginLeft : 0
        cmdIndex ()
    }

    /**
     * ESC H
     * C1.HTS
     *   DEC mnemonic: HTS (https://vt100.net/docs/vt510-rm/HTS.html)
     *   Sets a horizontal tab stop at the column position indicated by
     *   the value of the active column when the terminal receives an HTS.
     *
     * @vt: #Y   C1    HTS   "Horizontal Tabulation Set" "\x88"    "Places a tab stop at the current cursor position."
     * @vt: #Y   ESC   HTS   "Horizontal Tabulation Set" "ESC H"   "Places a tab stop at the current cursor position."
     */
    func cmdTabSet ()
    {
        buffer.tabSet (pos: buffer.x)
    }
    
    //
    // CSI Ps @
    // Insert Ps (Blank) Character(s) (default = 1) (ICH).
    //
    func cmdInsertChars (_ pars: [Int], _ collect: cstring)
    {
        // Do nothing if we are outside the margin
        if marginMode && (buffer.x < buffer.marginLeft || buffer.x > buffer.marginRight) {
            return
        }
        let cd = CharData (attribute: eraseAttr ())
        let buffer = self.buffer
        
        buffer.lines [buffer.y + buffer.yBase].insertCells (pos: buffer.x, n: pars.count > 0 ? max (pars [0], 1) : 1, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: cd)

        updateRange (buffer.y)
    }
    
    //
    // CSI Ps A
    // Cursor Up Ps Times (default = 1) (CUU).
    //
    func cmdCursorUp (_ pars: [Int], _ collect: cstring)
    {
        let param = max (pars.count > 0 ? pars [0] : 1, 1)
        let buffer = self.buffer
        var top = buffer.scrollTop
        
        if buffer.y < top {
            top = 0
        }
        if (buffer.y - param < top) {
            buffer.y = top
        } else {
            buffer.y -= param
        }
    }
    
    //
    // CSI Ps B
    // Cursor Down Ps Times (default = 1) (CUD).
    //
    func cmdCursorDown (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        let param = max (pars.count > 0 ? pars [0] : 1, 1)
        
        var bottom = buffer.scrollBottom
        // When the cursor starts below the scroll region, CUD moves it down to the
        // bottom of the screen.
        if buffer.y > bottom {
            bottom = buffer.rows-1
        }
        let newY = buffer.y + param

        if newY >= bottom {
                buffer.y = bottom
        } else {
                buffer.y = newY
        }
        // If the end of the line is hit, prevent this action from wrapping around to the next line.
        if buffer.x >= cols {
                buffer.x -= 1
        }
    }
    
    //
    // CSI Ps B
    // Cursor Forward Ps Times (default = 1) (CUF).
    //
    func cmdCursorForward (_ pars: [Int], _ collect: cstring)
    {
        cursorForward(count: pars.count > 0 ? pars [0] : 1)
    }
    
    func cursorForward (count: Int)
    {
        var right = marginMode ? buffer.marginRight : cols-1
        
        // When the cursor starts after the right margin, CUF moves to the full width
        if buffer.x > right {
            right = buffer.cols - 1
        }
        buffer.x += (max (count, 1))
        if buffer.x > right {
            buffer.x = right
        }
    }

    //
    // CSI Ps D
    // Cursor Backward Ps Times (default = 1) (CUB).
    //
    func cmdCursorBackward (_ pars: [Int], _ collect: cstring)
    {
        cursorBackward(count: pars.count > 0 ? pars [0] : 1)
    }
    
    func cursorBackward (count: Int)
    {
        let buffer = self.buffer
        
        // What is our left margin - depending on the settings.
        var left = marginMode ? buffer.marginLeft : 0
        
        // If the cursor is positioned before the margin, we can go backwards to the first column
        if buffer.x < left {
            left = 0
        }
        let newX = buffer.x - max (1, count)
        if newX < left {
            buffer.x = left
        } else {
            buffer.x = newX
        }
    }

    //
    // CSI Ps I
    //   Cursor Forward Tabulation Ps tab stops (default = 1) (CHT).
    //
    func cmdCursorForwardTab (_ pars: [Int], _ collect: cstring)
    {
        let param = min (cols-1, max (pars.count > 0 ? pars [0] : 1, 1))
        for _ in 0..<param {
            buffer.x = buffer.nextTabStop (marginMode: marginMode)
        }
    }
    
    /**
     * Restrict cursor to viewport size / scroll margin (origin mode)
     * - Parameter limitCols: by default it is true, but the reverseWraparound mechanism in Backspace needs `x` to go beyond.
     */
    func restrictCursor(_ limitCols: Bool = true)
    {
        buffer.x = min (cols - (limitCols ? 1 : 0), max (0, buffer.x))
        buffer.y = originMode
            ? min (buffer.scrollBottom, max (buffer.scrollTop, buffer.y))
            : min (rows - 1, max (0, buffer.y))
        
        updateRange(buffer.y)
    }

    //
    // CSI Ps ; Ps H
    // Cursor Position [row;column] (default = [1,1]) (CUP).
    //
    func cmdCursorPosition (_ pars: [Int], _ collect: cstring)
    {
        setCursor (col: pars.count >= 2 ? (max (1, pars [1])-1) : 0, row: pars.count >= 1 ? (max (1, pars [0]) - 1) : 0)
    }
    
    func setCursor (col: Int, row: Int)
    {
        updateRange(buffer.y)
        if originMode {
            buffer.x = col + (usingMargins () ? buffer.marginLeft : 0)
            buffer.y = buffer.scrollTop + row
        } else {
            buffer.x = col
            buffer.y = row
        }
        restrictCursor ()
    }

    //
    // CSI Ps E
    // Cursor Next Line Ps Times (default = 1) (CNL).
    // same as CSI Ps B?
    //
    func cmdCursorNextLine (_ pars: [Int], _ collect: cstring)
    {
        cmdCursorDown(pars, collect)
        buffer.x = buffer.marginLeft

        //return
        //let buffer = self.buffer
        //let param = max (pars.count > 0 ? pars [0] : 1, 1)
        //
        //var bottom = buffer.scrollBottom
        //// When the cursor starts below the scroll region, CUD moves it down to the
        //// bottom of the screen.
        //if buffer.y > bottom {
        //    bottom = buffer.rows-1
        //}
        //let newY = buffer.y + param
        //
        //if newY >= bottom {
        //        buffer.y = bottom
        //} else {
        //        buffer.y = newY
        //}
        //// If the end of the line is hit, prevent this action from wrapping around to the next line.
        //if buffer.x >= cols {
        //        buffer.x -= 1
        //}
        //buffer.x = buffer.marginLeft
    }

    //
    // CSI Ps F
    // Cursor Preceding Line Ps Times (default = 1) (CPL).
    // reuse CSI Ps A ?
    //
    func cmdCursorPrecedingLine (_ pars: [Int], _ collect: cstring)
    {
        cmdCursorUp(pars, collect)
        buffer.x = buffer.marginLeft
        
        //let param = max (pars.count > 0 ? pars [0] : 1, 1)
        //let buffer = self.buffer
        //var top = buffer.scrollTop
        //
        //if buffer.y < top {
        //    top = 0
        //}
        //if (buffer.y - param < top) {
        //    buffer.y = top
        //} else {
        //    buffer.y -= param
        //}
        //buffer.x = buffer.marginLeft
    }

    //
    // CSI Ps G
    // Cursor Character Absolute  [column] (default = [row,1]) (CHA).
    //
    func cmdCursorCharAbsolute (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        let param = max (pars.count > 0 ? pars [0] : 1, 1)

        buffer.x = (usingMargins() ? buffer.marginLeft : 0) + min (param - 1, cols - 1)
    }

    //
    // CSI Ps K  Erase in Line (EL).
    //     Ps = 0  -> Erase to Right (default).
    //     Ps = 1  -> Erase to Left.
    //     Ps = 2  -> Erase All.
    // CSI ? Ps K
    //   Erase in Line (DECSEL).
    //     Ps = 0  -> Selective Erase to Right (default).
    //     Ps = 1  -> Selective Erase to Left.
    //     Ps = 2  -> Selective Erase All.
    //
    func cmdEraseInLine (_ pars: [Int], _ collect: cstring)
    {
        let p = pars.count == 0 ? 0 : pars [0]
        
        switch p {
        case 0:
            eraseInBufferLine (y: buffer.y, start: buffer.x, end: cols)
        case 1:
            eraseInBufferLine (y: buffer.y, start: 0, end: buffer.x + 1)
        case 2:
            eraseInBufferLine (y: buffer.y, start: 0, end: cols)
        default:
            break
        }
        updateRange (buffer.y)
    }

    //
    // CSI Ps J  Erase in Display (ED).
    //     Ps = 0  -> Erase Below (default).
    //     Ps = 1  -> Erase Above.
    //     Ps = 2  -> Erase All.
    //     Ps = 3  -> Erase Saved Lines (xterm).
    // CSI ? Ps J
    //   Erase in Display (DECSED).
    //     Ps = 0  -> Selective Erase Below (default).
    //     Ps = 1  -> Selective Erase Above.
    //     Ps = 2  -> Selective Erase All.
    //
    func cmdEraseInDisplay (_ pars: [Int], _ collect: cstring)
    {
        let p = pars.count == 0 ? 0 : pars [0]
        var j: Int
        switch p {
        case 0:
            j = buffer.y
            updateRange (j)
            eraseInBufferLine (y: j, start: buffer.x, end: cols, clearWrap: buffer.x == 0)
            j += 1
            while j < rows {
                resetBufferLine (y: j)
                j += 1
            }
            updateRange (j - 1)
            
        case 1:
            j = buffer.y
            updateRange (j)
            // Deleted front part of line and everything before. This line will no longer be wrapped.
            eraseInBufferLine (y: j, start: 0, end: buffer.x + 1, clearWrap: true)
            if buffer.x + 1 >= cols {
                // Deleted entire previous line. This next line can no longer be wrapped.
                buffer.lines [j + 1].isWrapped = false
            }
            while (j != 0) {
                j -= 1
                resetBufferLine (y: j)
            }
            updateRange (0)
        case 2:
            j = rows
            updateRange (j - 1)
            while (j != 0) {
                j -= 1
                resetBufferLine (y: j)
            }
            updateRange (0)
        case 3:
            // Clear scrollback (everything not in viewport)
            let scrollBackSize = buffer.lines.count - rows
            if scrollBackSize > 0 {
                buffer.lines.trimStart (count: scrollBackSize)
                buffer.linesTop = 0
                buffer.yBase = max (buffer.yBase - scrollBackSize, 0)
                buffer.yDisp = max (buffer.yDisp - scrollBackSize, 0)
            }
            break;
        default:
            break
        }
    }

    //
    // Helper method to erase cells in a terminal row.
    // The cell gets replaced with the eraseChar of the terminal.
    // - Parameter y: row index
    // - Parameter start: first cell index to be erased
    // - Parameter end:   end - 1 is last erased cell
    //
    func eraseInBufferLine (y: Int, start: Int, end: Int, clearWrap: Bool = false, clearRenderMode: Bool = false)
    {
        let line = buffer.lines [buffer.yBase + y]
        line.images = nil
        let cd = CharData (attribute: eraseAttr ())
        line.replaceCells (start: start, end: end, fillData: cd)
        if clearWrap {
            line.isWrapped = false
        }
        if clearRenderMode {
            line.renderMode = .single
        }
    }
    
    //
    // CSI Ps L
    // Insert Ps Line(s) (default = 1) (IL).
    //
    func cmdInsertLines (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        if buffer.y < buffer.scrollTop || buffer.y > buffer.scrollBottom {
            return
        }
        // to prevent a Denial of Service
        let maxLines = buffer.lines.maxLength * 2
        var p = min (maxLines, max (pars.count == 0 ? 1 : pars [0], 1))
        let row = buffer.y + buffer.yBase
        
        let scrollBottomRowsOffset = rows - 1 - buffer.scrollBottom
        let scrollBottomAbsolute = rows - 1 + buffer.yBase - scrollBottomRowsOffset + 1
        
        let ea = eraseAttr ()
        if marginMode {
            if buffer.x >= buffer.marginLeft && buffer.x <= buffer.marginRight {
                let columnCount = buffer.marginRight-buffer.marginLeft+1
                let rowCount = buffer.scrollBottom-buffer.scrollTop
                for _ in 0..<p {
                    for i in (0..<rowCount).reversed() {
                        let src = buffer.lines [row+i]
                        let dst = buffer.lines [row+i+1]
                        
                        dst.copyFrom(src, srcCol: buffer.marginLeft, dstCol: buffer.marginLeft, len: columnCount)
                    }
                    
                    let last = buffer.lines [row]
                    last.fill (with: CharData (attribute: ea), atCol: buffer.marginLeft, len: columnCount)
                }
            }
        } else {
            for _ in 0..<p {
                p -= 1
                // test: echo -e '\e[44m\e[1L\e[0m'
                // blankLine(true) - xterm/linux behavior
                buffer.lines.splice (start: scrollBottomAbsolute - 1, deleteCount: 1, items: [],
                                     change: { line in updateRange (line) })
                let newLine = buffer.getBlankLine (attribute: ea)
                buffer.lines.splice (start: row, deleteCount: 0, items: [newLine], change: { line in updateRange (line) })
            }
        }
        // this.maxRange();
        updateRange (startLine: buffer.y, endLine: buffer.scrollBottom)
    }
    
    //
    // ESC ( C
    //   Designate G0 Character Set, VT100, ISO 2022.
    // ESC ) C
    //   Designate G1 Character Set (ISO 2022, VT100).
    // ESC * C
    //   Designate G2 Character Set (ISO 2022, VT220).
    // ESC + C
    //   Designate G3 Character Set (ISO 2022, VT220).
    // ESC - C
    //   Designate G1 Character Set (VT300).
    // ESC . C
    //   Designate G2 Character Set (VT300).
    // ESC / C
    //   Designate G3 Character Set (VT300). C = A  -> ISO Latin-1 Supplemental. - Supported?
    //
    func selectCharset (_ p: ArraySlice<UInt8>)
    {
        if p.count == 2 {
            // print ("Settin charset to \(p[1])")
        }
        
        if (p.count != 2) {
            cmdSelectDefaultCharset ()
            return
        }
        var ch: UInt8
        var charset: [UInt8:String]?
        
        if CharSets.all.keys.contains(p [1]){
            charset = CharSets.all [p [1]]!
        } else {
            charset = nil
        }
        
        switch p [0] {
        case UInt8 (ascii: "("):
            ch = 0
        case UInt8 (ascii: ")"):
            ch = 1
        case UInt8 (ascii: "-"):
            ch = 1
        case UInt8 (ascii: "*"):
            ch = 2
        case UInt8 (ascii: "."):
            ch = 2
        case UInt8 (ascii: "+"):
            ch = 3
        case UInt8 (ascii: "/"):
            ch = 3
        default:
            return;
        }
        setgCharset (ch, charset: charset)
    }

    func setLineRenderMode (to: BufferLine.RenderLineMode) {
        buffer.lines [buffer.y + buffer.yBase].renderMode = to
        updateRange (buffer.y)
    }
    
    //
    // ESC #6
    //
    func cmdDoubleWidthSingleHeight ()
    {
        setLineRenderMode(to: .doubleWidth)
    }
    
    //
    // dhtop
    //
    func cmdSetDoubleHeightTop ()
    {
        setLineRenderMode(to: .doubledTop)
    }
    
    // dhbot
    func cmdSetDoubleHeightBottom ()
    {
        setLineRenderMode(to: .doubledDown)
    }
    
    //
    // swsh
    //
    func cmdSingleWidthSingleHeight ()
    {
        setLineRenderMode(to: .single)
    }
    
    // ESC # 8
    func cmdScreenAlignmentPattern ()
    {
        let cell = CharData(attribute: curAttr.justColor(), char: "E")

        setCursor (col: 0, row: 0)
        for yOffset in 0..<rows {
            let rowN = buffer.y + buffer.yBase + yOffset
            buffer.lines [rowN].fill(with: cell)
            buffer.lines [rowN].isWrapped = false
        }
        updateFullScreen()
        setCursor(col: 0, row: 0)
    }

    func cmdRestoreCursor (_ pars: [Int], _ collect: cstring)
    {
        // avoid kitty keyboard protocol
        if pars.count > 0 {
            return
        }

        buffer.x = buffer.savedX
        buffer.y = buffer.savedY
        curAttr = buffer.savedAttr
        charset = buffer.savedCharset
        originMode = buffer.savedOriginMode
        setMarginMode(buffer.savedMarginMode)
        setWraparound(buffer.savedWraparound)
        reverseWraparound = buffer.savedReverseWraparound
    }

    //
    // Validates optional arguments for top, left, bottom, right sent by various
    // escape sequences and returns validated top, left, bottom, right in our 0-based
    // internal coordinates
    //
    func getRectangleFromRequest (_ pars: ArraySlice<Int>) -> (top: Int, left: Int, bottom: Int, right: Int)?
    {
        let buffer = self.buffer
        let b = pars.startIndex
        var top = max (1, pars.count > 0 ? pars [b] : 1)
        var left = max (pars.count > 1 ? pars [b+1] : 1, 1)
        var bottom = pars.count > 2 ? pars [b+2] : -1
        var right = pars.count > 3 ? pars [b+3] : -1

        if bottom < 0 {
            bottom = rows
        }
        if right < 0 {
            right = cols
        }
        if right > cols {
            right = cols
        }
        if bottom > rows {
            bottom = rows
        }
        if originMode {
            top += buffer.scrollTop
            bottom += buffer.scrollTop
            left += buffer.marginLeft
            right += buffer.marginLeft
        }
        if top > bottom || left > right {
            return nil
        }
        //top = min (top, bottom)
        //left = min (left, right)
        let rowBound = rows-1
        let colBound = cols-1
        return (min (rowBound, top-1), min (colBound, left-1), min (rowBound, bottom-1), min (colBound, right-1))
    }
    
    //
    // Copy Rectangular Area (DECCRA), VT400 and up.
    // CSI Pts ; Pls ; Pbs ; Prs ; Pps ; Ptd ; Pld ; Ppd $ v
    //  Pts ; Pls ; Pbs ; Prs denotes the source rectangle.
    //  Pps denotes the source page.
    //  Ptd ; Pld denotes the target location.
    //  Ppd denotes the target page.
    func csiCopyRectangularArea (_ ipars: [Int], _ collect: cstring)
    {
        if collect.count > 0 && collect == [36] {
            var pars: [Int] = []
            pars.append (ipars.count > 1 && ipars [0] != 0 ? ipars [0] : 1) // Pts default 1
            pars.append (ipars.count > 2 && ipars [1] != 0 ? ipars [1]: 1) // Pls default 1
            pars.append (ipars.count > 3 && ipars [2] != 0 ? ipars [2]: rows-1) // Pbs default to last line of page
            pars.append (ipars.count > 4 && ipars [3] != 0 ? ipars [3]: cols-1) // Prs defaults to last column
            pars.append (ipars.count > 5 && ipars [4] != 0 ? ipars [4]: 1) // Pps page source = 1
            pars.append (ipars.count > 6 && ipars [5] != 0 ? ipars [5]: 1) // Ptd default is 1
            pars.append (ipars.count > 7 && ipars [6] != 0 ? ipars [6]: 1) // Pld default is 1
            pars.append (ipars.count > 8 && ipars [7] != 0 ? ipars [7]: 1) // Ppd default is 1
            
            // We only support copying on the same page, and the page being 1
            if pars [4] == pars [7] && pars [4] == 1 {
                if let (top, left, bottom, right) = getRectangleFromRequest(pars [0...3]) {
                    let rowTarget = min (rows-1, pars [5]-1)
                    let colTarget = min (cols-1, pars [6]-1)
                    
                    // Block size
                    let columns = right-left+1
                    
                    let cright = min (cols-1, left + min (columns, cols-colTarget))
                    
                    var lines: [[CharData]] = []
                    for row in top...bottom {
                        let line = buffer.lines [row+buffer.yBase]
                        var lineCopy: [CharData] = []
                        for col in left...cright {
                            lineCopy.append(line [col])
                        }
                        lines.append(lineCopy)
                    }
                    
                    for row in 0...(bottom-top) {
                        if row+rowTarget >= buffer.rows {
                            break
                        }
                        let line = buffer.lines [row+rowTarget+buffer.yBase]
                        let lr = lines [row]
                        for col in 0..<(cright-left) {
                            if col >= buffer.cols {
                                break
                            }
                            line [colTarget+col] = lr [col]
                        }
                    }
                }
            }
        }
    }

    // CSI Ps x  Request Terminal Parameters (DECREQTPARM).
    // CSI Ps * x Select Attribute Change Extent (DECSACE), VT420 and up.
    // CSI Pc ; Pt ; Pl ; Pb ; Pr $ x Fill Rectangular Area (DECFRA), VT420 and up.
    func csiX (_ pars: [Int], _ collect: cstring)
    {
        if collect.count > 0 && collect == [UInt8 (ascii: "$")] {
            // DECFRA
            if let (top, left, bottom, right) = getRectangleFromRequest(pars [1...]) {
                for row in top...bottom {
                    let line = buffer.lines [row+buffer.yBase]
                    for col in left...right {
                        line [col] = CharData(attribute: curAttr, char: Character (UnicodeScalar (pars [0]) ?? " "))
                    }
                }
            }
        } else {
            log ("Not implemented CSI x with collect: collect=\(collect) and pars=\(pars)")
        }
    }

    //
    // CSI # }   Pop video attributes from stack (XTPOPSGR), xterm.  Popping
    //           restores the video-attributes which were saved using XTPUSHSGR
    //           to their previous state.
    //
    // CSI Pm ' }
    //           Insert Ps Column(s) (default = 1) (DECIC), VT420 and up.
    //
    func csiCloseBrace (_ pars: [Int], _ collect: cstring)
    {
        if collect.count > 0 && collect == [39 /* ' */] {
             // DECIC - Insert Column
            let n = pars.count > 0 ? max (pars [0],1) : 1
            let buffer = self.buffer
            
            if marginMode && buffer.x < buffer.marginLeft || buffer.x > buffer.marginRight {
                return
            }
            
            for row in buffer.scrollTop...buffer.scrollBottom {
                let line = buffer.lines [row+buffer.yBase]
                line.insertCells(pos: buffer.x, n: n, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: buffer.getNullCell())
                line.isWrapped = false
            }
            return
        } else {
            log ("CSI # } not implemented- XTPOPSGR with \(pars)")
        }
    }
    
    // Required by the test suite
    // CSI Pi ; Pg ; Pt ; Pl ; Pb ; Pr * y
    // Request Checksum of Rectangular Area (DECRQCRA), VT420 and up.
    // Response is
    // DCS Pi ! ~ x x x x ST
    //   Pi is the request id.
    //   Pg is the page number.
    //   Pt ; Pl ; Pb ; Pr denotes the rectangle.
    //   The x's are hexadecimal digits 0-9 and A-F.
    func cmdDECRQCRA (_ pars: [Int], _ collect: cstring)
    {
        var checksum: UInt32 = 0
        let rid = pars.count > 0 ? pars [0] : 1
        let _ = pars.count > 1 ? pars [1] : 0
        var result = "0000"
        if (tdel?.isProcessTrusted(source: self) ?? false) && pars.count > 2 {
            if let (top, left, bottom, right) = getRectangleFromRequest(pars [2...]) {
                for row in top...bottom {
                    let line = buffer.lines [row+buffer.yBase]
                    for col in left...right {
                        let cd = line [col]
                        let ch = cd.code == 0 ? " " : cd.getCharacter()
                        
                        for scalar in ch.unicodeScalars {
                            checksum += scalar.value
                        }
                    }
                }
            }
            result = String(format: "%04x", checksum)
        }
        sendResponse (cc.DCS, "\(rid)!~\(result)", cc.ST)
    }

    // Dispatcher for CSI .* z commands
    func csiZ (_ pars: [Int], _ collect: cstring)
    {
        switch collect {
        case [UInt8 (ascii: "$")]:
            cmdDECERA (pars)
        case [UInt8 (ascii: "'")]:
            // Enable Locator Reporting (DECELR).
            // Valid values for the first parameter:
            //   Ps = 0  ⇒  Locator disabled (default).
            //   Ps = 1  ⇒  Locator enabled.
            //   Ps = 2  ⇒  Locator enabled for one report, then disabled.
            // The second parameter specifies the coordinate unit for locator
            // reports.
            // Valid values for the second parameter:
            //   Pu = 0  or omitted ⇒  default to character cells.
            //   Pu = 1  ⇐  device physical pixels.
            //   Pu = 2  ⇐  character cells.
            print ("TODO: Enable Locator Reporting (DECELR)")
        default:
            break
        }
    }
    
    // DECERA - Erase Rectangular Area
    // CSI Pt ; Pl ; Pb ; Pr ; $ z
    func cmdDECERA (_ pars: [Int])
    {
        if let (top, left, bottom, right) = getRectangleFromRequest(pars [0...]) {
            for row in top...bottom {
                let line = buffer.lines [row+buffer.yBase]
                for col in left...right {
                    line [col] = CharData(attribute: curAttr, char: " ", size: 1)
                }
            }
        }
    }

    // Dispatches to DECSERA or XTPUSHSGR
    func csiOpenBrace (_ pars: [Int], _ collect: cstring)
    {
        if collect.count > 0 && collect == [UInt8 (ascii: "$")] {
            cmdSelectiveEraseRectangularArea (pars)
        } else {
            log ("CSI # { not implemented - XTPUSHSGR with \(pars)")
        }
    }
    
    // Push video attributes onto stack (XTPUSHSGR), xterm.
    func cmdPushSg (_ pars: [Int])
    {
        
    }
    
    // DECSERA - Selective Erase Rectangular Area
    // CSI Pt ; Pl ; Pb ; Pr ; $ {
    func cmdSelectiveEraseRectangularArea (_ pars: [Int])
    {
        if let (top, left, bottom, right) = getRectangleFromRequest(pars [0...]) {
            for row in top...bottom {
                let line = buffer.lines [row+buffer.yBase]
                for col in left...right {
                    var cd = line [col]
                    cd.setValue(char: " ", size: 1)
                    line [col] = cd
                }
            }
        }
    }
    /**
     * Commands send to the `windowCommand` delegate for the front-end to implement capabilities
     * on behalf of the client.  The expected return strings in some of these enumeration values is documented
     * below.   Returns are only expected for the enum values that start with the prefix `report`
     */
    public enum WindowManipulationCommand {
        /// Raised when the backend should deiconify a window, no return expected
        case deiconifyWindow
        /// Raised when the backend should iconify  a window, no return expected
        case iconifyWindow
        /// Raised when the client would like the window to be moved to the x,y position int he screen, not return expected
        case moveWindowTo(x: Int, y: Int)
        /// Raised when the client would like the window to be resized to the specified widht and heigh in pixels, not return expected
        case resizeWindowTo(width: Int, height: Int)
        /// Raised to bring the terminal to the front
        case bringToFront
        /// Send the terminal to the back if possible
        case sendToBack
        /// Trigger a terminal refresh
        case refreshWindow
        /// Request that the size of the terminal be changed to the specified cols and rows
        case resizeTo(cols: Int, rows: Int)
        case restoreMaximizedWindow
        /// Attempt to maximize the window
        case maximizeWindow
        /// Attempt to maximize the window vertically
        case maximizeWindowVertically
        /// Attempt to maximize the window horizontally
        case maximizeWindowHorizontally
        case undoFullScreen
        case switchToFullScreen
        case toggleFullScreen
        case reportTerminalState
        case reportTerminalPosition
        case reportTextAreaPosition
        case reporttextAreaPixelDimension
        case reportSizeOfScreenInPixels
        case reportCellSizeInPixels
        case reportTextAreaCharacters
        case reportScreenSizeCharacters
        case reportIconLabel
        case reportWindowTitle
        case resizeTo (lines: Int)
    }

    // Dispatches to
    func csit (_ pars: [Int], _ collect: cstring)
    {
        switch collect {
        case []:
            cmdWindowOptions(pars)
        case [UInt8 (ascii: ">")]:
            cmdXtermTitleModeSet(pars)
        default:
            log ("Unhandled csiT \(collect)")
        }
    }
    
    func cmdXtermTitleModeSet (_ pars: [Int])
    {
        // Use the windowTextEncoding type
        for par in pars {
            switch par {
            case 0:
                // Set window/icon labels using hexadecimal.
                xtermTitleSetHex = true
                break
            case 1:
                // Query window/icon labels using hexadecimal.
                xtermTitleQueryHex = true
                break
            case 2:
                // Set window/icon labels using UTF-8.
                xtermTitleSetUtf = true
                break
            case 3:
                // Query window/icon labels using UTF-8.
                xtermTitleQueryUtf = true
                break
            default:
                break
            }
        }
    }
    
    func cmdXtermTitleModeReset (_ pars: [Int])
    {
        // Use the windowTextEncoding type
        for par in pars {
            switch par {
            case 0:
                // Do not set window/icon labels using hexadecimal.
                xtermTitleSetHex = false
                break
            case 1:
                // Do not query window/icon labels using hexadecimal
                xtermTitleQueryHex = false
                break
            case 2:
                // Do not set window/icon labels using UTF-8.
                xtermTitleSetUtf = false
                break
            case 3:
                // Do not query window/icon labels using UTF-8.
                xtermTitleQueryUtf = false
                break
            default:
                break
            }
        }
    }

    //
    // CSI Ps ; Ps ; Ps t - Various window manipulations and reports (xterm)
    // See https://invisible-island.net/xterm/ctlseqs/ctlseqs.html for a full
    // list of commans for this escape sequence
    func cmdWindowOptions (_ pars: [Int])
    {
        guard let tdel = self.tdel else {
            return
        }
        switch pars {
        case [1]:
            tdel.windowCommand(source: self, command: .deiconifyWindow)
        case [2]:
            tdel.windowCommand(source: self, command: .iconifyWindow)
        case _ where pars.count == 3 && pars.first == 3:
            tdel.windowCommand(source: self, command: .moveWindowTo(x: pars [1], y: pars[2]))
        case _ where pars.count == 3 && pars.first == 4:
            tdel.windowCommand(source: self, command: .moveWindowTo(x: pars [1], y: pars[2]))
        case [5]:
            tdel.windowCommand(source: self, command: .bringToFront)
        case [6]:
            tdel.windowCommand(source: self, command: .sendToBack)
        case [7]:
            tdel.windowCommand(source: self, command: .refreshWindow)
        case _ where pars.count == 3 && pars.first == 8:
            tdel.windowCommand(source: self, command: .resizeTo(cols: pars [1], rows: pars [2]))
        case [9, 0]:
            tdel.windowCommand(source: self, command: .restoreMaximizedWindow)
        case [9, 1]:
            tdel.windowCommand(source: self, command: .maximizeWindow)
        case [9, 2]:
            tdel.windowCommand(source: self, command: .maximizeWindowVertically)
        case [9, 3]:
            tdel.windowCommand(source: self, command: .maximizeWindowHorizontally)
        case [10, 0]:
            tdel.windowCommand(source: self, command: .undoFullScreen)
        case [10, 1]:
            tdel.windowCommand(source: self, command: .switchToFullScreen)
        case [10, 2]:
            tdel.windowCommand(source: self, command: .toggleFullScreen)
        case [15]: // Report size in pixels
            if let r = tdel.windowCommand(source: self, command: .reportSizeOfScreenInPixels) {
                sendResponse(r)
            } else {
                sendResponse (cc.CSI, "5;768;1024t")
            }
        case [16]: // Report cell size in pixels
            // If no value is returned send 16x10
            // TODO: should surface that to the UI, should not do this here
            if let r = tdel.windowCommand(source: self, command: .reportCellSizeInPixels) {
                sendResponse(r)
            } else {
                sendResponse (cc.CSI, "6;16;10t")
            }
        case [18]:
            if let r = tdel.windowCommand(source: self, command: .reportCellSizeInPixels) {
                sendResponse(r)
            } else {
                sendResponse(cc.CSI, "8;\(rows);\(cols)t")
            }
        case [19]:
            if let r = tdel.windowCommand(source: self, command: .reportScreenSizeCharacters) {
                sendResponse(r)
            } else {
                sendResponse(cc.CSI, "9;\(rows);\(cols)t")
            }
        case [20]:
            // Do not report the actual title back, as it can be exploited,
            // https://marc.info/?l=bugtraq&m=104612710031920&w=2
            sendResponse (cc.OSC, "L", cc.ST)
        case [21]:
            // Do not report the actual content of the title back, as it can be exploited,
            // https://marc.info/?l=bugtraq&m=104612710031920&w=2
            sendResponse (cc.OSC, "l", cc.ST)
        case [22, 0], [22, 0, 0]:
            terminalTitleStack = terminalTitleStack + [terminalTitle]
            terminalIconStack = terminalIconStack + [iconTitle]
        case [22, 1]:
            terminalIconStack = terminalIconStack + [iconTitle]
        case [22, 2]:
            terminalTitleStack = terminalTitleStack + [terminalTitle]
        case [23, 0], [23, 0, 0]:
            if let nt = terminalTitleStack.last {
                terminalTitleStack = terminalTitleStack.dropLast()
                setTitle(text: nt)
            }
            if let nt = terminalIconStack.last {
                terminalIconStack = terminalIconStack.dropLast()
                setIconTitle(text: nt)
            }
        case [23, 1]:
            if let nt = terminalTitleStack.last {
                terminalTitleStack = terminalTitleStack.dropLast()
                setTitle(text: nt)
            }
        case [23, 2]:
            if let nt = terminalIconStack.last {
                terminalIconStack = terminalIconStack.dropLast()
                setIconTitle(text: nt)
            }

        default:
            log ("Unhandled Window command: \(pars)")
            break
        }
    }

    func cmdSetMargins (_ pars: [Int], _ collect: cstring)
    {
        var left = min (cols-1, max (0, (pars.count > 0 ? pars[0] : 1) - 1))
        let right = min (cols-1, max (0, (pars.count > 1 ? pars [1] : cols) - 1))
        
        left = min (left, right)
        buffer.marginLeft = left
        buffer.marginRight = right
    }
    
    //
    //  CSI s (sometimes, if the margin mode is false)
    //  ESC 7
    //   Save cursor (ANSI.SYS).
    //
    func cmdSaveCursor (_ pars: [Int], _ collect: cstring)
    {
        buffer.savedX = buffer.x
        buffer.savedY = buffer.y
        buffer.savedAttr = curAttr
        buffer.savedCharset = charset
        buffer.savedWraparound = wraparound
        buffer.savedOriginMode = originMode
        buffer.savedMarginMode = marginMode
        buffer.savedReverseWraparound = reverseWraparound
    }

    //
    // CSI Ps ; Ps r
    //   Set Scrolling Region [top;bottom] (default = full size of window) (DECSTBM).
    // CSI ? Pm r
    //
    func cmdSetScrollRegion (_ pars: [Int], _ collect: cstring)
    {
        if collect != [] {
            return
        }
        let buffer = self.buffer
        let top = pars.count > 0 ? max (pars [0] - 1, 0) : 0
        var bottom = rows
        if pars.count > 1 {
            // bottom = 0 means "bottom of the screen"
            let p = pars [1]
            if p != 0 {
                bottom = min (pars [1], rows)
            }
        }
        // normalize
        bottom -= 1
        
        // only set the scroll region if top < bottom
        if top < bottom {
            buffer.scrollBottom = bottom
            buffer.scrollTop = top
        }
        setCursor(col: 0, row: 0)
    }

    public func setCursorStyle (_ style: CursorStyle)
    {
        if options.cursorStyle != style {
            tdel?.cursorStyleChanged(source: self, newStyle: style)
            options.cursorStyle = style
        }
    }
    
    //
    // CSI Ps SP q  Set cursor style (DECSCUSR, VT520).
    //   Ps = 0  -> blinking block.
    //   Ps = 1  -> blinking block (default).
    //   Ps = 2  -> steady block.
    //   Ps = 3  -> blinking underline.
    //   Ps = 4  -> steady underline.
    //   Ps = 5  -> blinking bar (xterm).
    //   Ps = 6  -> steady bar (xterm).
    //
    func cmdSetCursorStyle (_ pars: [Int], _ collect: cstring)
    {
        if collect.count == 0 || collect != [32] { /* space */
            return
        }
        let p = max (pars.count == 0 ? 1 : pars [0], 1)
        switch (p) {
        case 1, 0:
            setCursorStyle (.blinkBlock)
        case 2:
            setCursorStyle (.steadyBlock)
        case 3:
            setCursorStyle (.blinkUnderline)
        case 4:
            setCursorStyle (.steadyUnderline)
        case 5:
            setCursorStyle (.blinkBar)
        case 6:
            setCursorStyle (.steadyBar)
        default:
            break;
        }
    }

    func cmdDecRqm (_ pars: [Int], decMode: Bool) {
        let modeUnknown = 0
        let modeSet = 1
        let modeReset = 2
        //let modeAlwaysSet = 3
        let modeAlwaysReset = 4
        
        // Same as reset for now, but it is something that should change if the companion setting is ever implemented
        let modeCouldBeImplementedButReset = 2
        let modeCouldBeImplementedButSet = 1
        
        guard let mode = pars.first else {
            sendResponse (cc.CSI, ";0$y")
            return
        }
        var res = modeUnknown
        if decMode {
            switch mode {
            case 1: // DECCKM
                res = applicationCursor ? modeSet : modeReset
            case 2: // DECCKM - reserved for VT52 emulation
                res = modeSet
            case 3: // DECCOLM - 132 Column Mode
                res = buffer.cols == 132 ? modeSet : modeReset
            case 4: // DECSCLM - Smooth/jump scroll, we dont implement
                res = smoothScroll ? modeSet : modeReset
            case 5: // DECSCNM - Reverse Display Colors
                res = curAttr == CharData.invertedAttr ? modeSet : modeReset
            case 6: // DECOM - cursor origin
                res = originMode ? modeSet : modeReset
            case 7: // DECAWM - Wraparound Mode
                res = wraparound ? modeSet : modeReset
            case 8: // DECARM - Autorepeat mode
                res = modeCouldBeImplementedButSet
            case 9:
                res = mouseMode == .x10 ? modeSet : modeReset
            case 10:
                res = modeAlwaysReset
            case 12: // ATT610_BLINK
                res = cursorBlink ? modeSet : modeReset
            case 13: // user cursor blink setting
                res = modeCouldBeImplementedButReset
            case 14: // cursor blink xor
                res = modeCouldBeImplementedButReset
            case 18: // DECPFF - Print screen with form feed
                res = modeCouldBeImplementedButSet
            case 19: // DECPEX - print region limitation
                res = modeCouldBeImplementedButSet
            case 25: // DECTCEM cursor visbiolity
                res = cursorHidden ? modeReset : modeSet
            case 30: // RXVT show scrollbar
                res = modeCouldBeImplementedButReset
            case 40: // Enable 80 to 132 transition
                res = allow80To132 ? modeSet : modeReset
            case 41: // xterm tab workaround in "more(1)" command
                res = modeReset
            case 42: // DECNRCM - national character set
                res = modeAlwaysReset
            case 44: // MARGIN_BELL
                res = modeAlwaysReset
            case 45: // REVERSEWRAP
                res = reverseWraparound ? modeSet : modeReset
            case 46: // allow logging
                res = modeAlwaysReset
            case 47: // ALTBUF - alternate screen buffer
                res = isCurrentBufferAlternate ? modeSet : modeReset
            case 66: // DECNKCM
                res = applicationKeypad ? modeSet : modeReset
            case 67: // backspace sends delete
                res = modeAlwaysReset
            case 69: // DECLRMM - mmargins
                res = marginMode ? modeSet : modeReset
            case 80: // DECSDM - Sixel scrolling
                res = modeAlwaysReset
            case 95: // DECNCSM - clear on DECCOLM changes
                res = modeCouldBeImplementedButSet
            case 1000:
                res = mouseMode == .vt200 ? modeSet : modeReset
            case 1001:
                res = modeCouldBeImplementedButReset
            case 1002:
                res = mouseMode == .buttonEventTracking ? modeSet : modeReset
            case 1003:
                res = mouseMode == .anyEvent ? modeSet : modeReset
            case 1004:
                res = sendFocus ? modeSet : modeReset
            case 1005:
                res = mouseProtocol == .utf8 ? modeSet : modeReset
            case 1006:
                res = mouseProtocol == .sgr ? modeSet : modeReset
            case 1015:
                res = mouseProtocol == .urxvt ? modeSet : modeReset
            case 1016:
                res = mouseProtocol == .sgrPixel ? modeSet : modeReset
            case 1034:
                // This is the esc+key toggles top bit, in this UTF world, I dont think it is worth support it ever.
                res = modeAlwaysReset
                // 1035, 1036, 1037, 1039, 1040, 1042, 1043, 1046
                // 1047 - what does this even do?
                // 1048, 1049,
                // keyboard emulation mode: 1050, 1051, 1052, 1053, 1060, 1061
            case 2004:
                res = bracketedPasteMode ? modeSet : modeReset
            default:
                break
            }
        } else {
            switch mode {
            case 1: // GATM - guarded area transfer
                res = modeAlwaysReset
            case 2: // Disable keyboard input KAM
                // If implemented elsewhere, this can be added here, but I have reservations about this
                res = modeCouldBeImplementedButReset
            case 3: // CRM - Display control characters
                res = modeCouldBeImplementedButReset
            case 4: // IRM Insert mode
                res = insertMode ? modeSet : modeReset
            case 5: // SRTM Status reporting transfer
                res = modeAlwaysReset
            case 7: // VEM vertical editing
                res = modeAlwaysReset
            case 10: // HEM horizontal editing
                res = modeAlwaysReset
            case 11: // PUM positioning unit
                res = modeAlwaysReset
            case 12: // SRM send-receive mode, update when we implement
                res = modeCouldBeImplementedButSet
            case 13: // FEAM Format effector action
                res = modeAlwaysReset
            case 14: // FETM Format effector transfer
                res = modeAlwaysReset
            case 15: // MATM Multiple area transfer
                res = modeAlwaysReset
            case 16: // TTM transfer termination
                res = modeAlwaysReset
            case 17: // SATM selected area transfer
                res = modeAlwaysReset
            case 18: // TSM tabulation stop
                res = modeAlwaysReset
            case 19: // EBM Editing Boundary
                res = modeAlwaysReset
            case 20: // LNM Line feed/newline
                res = lineFeedMode ? modeSet : modeReset
            default:
                break
            }
        }
        if decMode {
            sendResponse (cc.CSI, "?\(mode);\(res)$y")
        } else {
            sendResponse (cc.CSI, "\(mode);\(res)$y")
        }
    }
    
    //
    // Proxy for various CSI .* p commands
    func csiPHandler (_ pars: [Int], _ collect: cstring)
    {
        switch collect {
        case [UInt8 (ascii: "!")]:
            cmdSoftReset ()
        case [UInt8 (ascii: "\"")]:
            cmdSetConformanceLevel (pars, collect)
            
            // DECRQM - CSI ? Pa $ p
            // Request DEC mode
        case [63, 36]:
            cmdDecRqm (pars, decMode: true);
        
            // DECRQM - CSI Pa $ p
            // Request ANSI mode
        case [36]:
            cmdDecRqm (pars, decMode: false);
        default:
            var r = ""
            for x in collect {
                r.append ("\(x)")
            }
            log ("Unhandled CSI \(r) with pars=\(pars)")
        }
    }
    
    // CSI Pl ; Pc " p
    // Set conformance level (DECSCL), VT220 and up
    func cmdSetConformanceLevel (_ pars: [Int], _ collect: cstring)
    {
        if pars.count > 0 {
            let level = pars [0]
            switch level {
            case 61:
                conformance = .vt100
                cc.send8bit = false
            case 62:
                conformance = .vt200
            case 63:
                conformance = .vt300
            case 64:
                conformance = .vt400
            case 65:
                conformance = .vt500
            default:
                conformance = .vt500
            }
        }
        if pars.count > 1 && conformance != .vt100 {
            switch pars [1] {
            case 0:
                cc.send8bit = true
            case 2:
                cc.send8bit = true
            default:
                cc.send8bit = false
            }
        }
    }
    
    //
    // http://vt100.net/docs/vt220-rm/table4-10.html
    //
    /* ! - CSI ! p   Soft terminal reset (DECSTR). */
    func cmdSoftReset ()
    {
        cursorHidden = false
        insertMode = false
        originMode = false

        reverseWraparound = false
        
        setWraparound(true)  // defaults: xterm - true, vt100 - false
        applicationKeypad = false
        syncScrollArea ()
        applicationCursor = false
        buffer.scrollTop = 0
        buffer.scrollBottom = rows - 1
        curAttr = CharData.defaultAttr
        buffer.softReset ()

        charset = nil
        setgLevel (0)
        conformance = .vt500
        hyperLinkTracking = nil
        lineFeedMode = options.convertEol
        resetAllColors()
        tdel?.showCursor(source: self)
        // MIGUEL TODO:
        // TODO: audit any new variables, those in setup might be useful
    }

    /// Performs a terminal soft-reset, the equivalent of the DECSTR sequence
    /// For a full reset see `resetToInitialState`
    public func softReset ()
    {
        cmdSoftReset()
    }
    
    //
    // CSI Ps n  Device Status Report (DSR).
    //     Ps = 5  -> Status Report.  Result (``OK'') is
    //   CSI 0 n
    //     Ps = 6  -> Report Cursor Position (CPR) [row;column].
    //   Result is
    //   CSI r ; c R
    // CSI ? Ps n
    //   Device Status Report (DSR, DEC-specific).
    //     Ps = 6  -> Report Cursor Position (CPR) [row;column] as CSI
    //     ? r ; c R (assumes page is zero).
    //     Ps = 1 5  -> Report Printer status as CSI ? 1 0  n  (ready).
    //     or CSI ? 1 1  n  (not ready).
    //     Ps = 2 5  -> Report UDK status as CSI ? 2 0  n  (unlocked)
    //     or CSI ? 2 1  n  (locked).
    //     Ps = 2 6  -> Report Keyboard status as
    //   CSI ? 2 7  ;  1  ;  0  ;  0  n  (North American).
    //   The last two parameters apply to VT400 & up, and denote key-
    //   board ready and LK01 respectively.
    //     Ps = 5 3  -> Report Locator status as
    //   CSI ? 5 3  n  Locator available, if compiled-in, or
    //   CSI ? 5 0  n  No Locator, if not.
    //
    func cmdDeviceStatus (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        if collect.count == 0 {
            switch (pars [0]) {
            case 5:
                // status report
                sendResponse (cc.CSI, "0n")
            case 6:
                // cursor position
                let y = max (1, buffer.y + 1 - (originMode ? buffer.scrollTop : 0))
                
                // Need the max, because the cursor could be before the leftMargin
                let x = max (1, buffer.x + 1 - (originMode ? buffer.marginLeft : 0))
                sendResponse (cc.CSI, "\(y);\(x)R")
            default:
                break;
            }
        } else if (collect == [UInt8 (ascii: "?")]) {
            // modern xterm doesnt seem to
            // respond to any of these except ?6, 6, and 5
            switch pars [0] {
            case 6:
                // cursor position
                let y = buffer.y + 1 - (originMode ? buffer.scrollTop : 0)
                // Need the max, because the cursor could be before the leftMargin
                let x = max (1, buffer.x + 1  - (usingMargins () ? buffer.marginLeft : 0))
                sendResponse (cc.CSI, "?\(y);\(x);1R")
            case 15:
                // Request printer status report, we respond "We are ready"
                sendResponse(cc.CSI, "?10n")
                break;
            case 25:
                // We respond "User defined keys are locked"
                sendResponse(cc.CSI, "?21n")
                break;
            case 26:
                // Requests keyboard type
                // We respond "American keyboard", TODO: worth plugging something else?  Mac perhaps?
                sendResponse(cc.CSI, "?27;1;0;0n")
    
                break;
            case 53:
                // TODO: no dec locator/mouse
                // this.handler(C0.ESC + '[?50n');
                break;
            case 55:
                // Request locator status
                sendResponse(cc.CSI, "?53n")
            case 56:
                // What kind of locator we have, we reply mouse, but perhaps on iOS we should respond something else
                sendResponse(cc.CSI, "?57;1n")
            case 62:
                // Macro space report
                sendResponse(cc.CSI, "0*{")
            case 63:
                // Requests checksum of macros, we return 0
                let id = pars.count > 1 ? pars [1] : 0
                sendResponse(cc.DCS, "\(id)!~0000", cc.ST)
            case 75:
                // Data integrity report, no issues:
                sendResponse (cc.CSI, "?70n")
            case 85:
                // Multiple session status, we reply single session
                sendResponse (cc.CSI, "?83n")
            default:
                break
            }
        }
    }

    //
    // CSI Pm m  Character Attributes (SGR).
    //     Ps = 0  -> Normal (default).
    //     Ps = 1  -> Bold.
    //     Ps = 2  -> Faint, decreased intensity (ISO 6429).
    //     Ps = 4  -> Underlined.
    //     Ps = 5  -> Blink (appears as Bold).
    //     Ps = 7  -> Inverse.
    //     Ps = 8  -> Invisible, i.e., hidden (VT300).
    //     Ps = 9  -> Crossed out character
    //     Ps = 2 2  -> Normal (neither bold nor faint).
    //     Ps = 2 4  -> Not underlined.
    //     Ps = 2 5  -> Steady (not blinking).
    //     Ps = 2 7  -> Positive (not inverse).
    //     Ps = 2 8  -> Visible, i.e., not hidden (VT300).
    //     Ps = 2 9  -> Not crossed out
    //     Ps = 3 0  -> Set foreground color to Black.
    //     Ps = 3 1  -> Set foreground color to Red.
    //     Ps = 3 2  -> Set foreground color to Green.
    //     Ps = 3 3  -> Set foreground color to Yellow.
    //     Ps = 3 4  -> Set foreground color to Blue.
    //     Ps = 3 5  -> Set foreground color to Magenta.
    //     Ps = 3 6  -> Set foreground color to Cyan.
    //     Ps = 3 7  -> Set foreground color to White.
    //     Ps = 3 9  -> Set foreground color to default (original).
    //     Ps = 4 0  -> Set background color to Black.
    //     Ps = 4 1  -> Set background color to Red.
    //     Ps = 4 2  -> Set background color to Green.
    //     Ps = 4 3  -> Set background color to Yellow.
    //     Ps = 4 4  -> Set background color to Blue.
    //     Ps = 4 5  -> Set background color to Magenta.
    //     Ps = 4 6  -> Set background color to Cyan.
    //     Ps = 4 7  -> Set background color to White.
    //     Ps = 4 9  -> Set background color to default (original).
    //
    //   If 16-color support is compiled, the following apply.  Assume
    //   that xterm's resources are set so that the ISO color codes are
    //   the first 8 of a set of 16.  Then the aixterm colors are the
    //   bright versions of the ISO colors:
    //     Ps = 9 0  -> Set foreground color to Black.
    //     Ps = 9 1  -> Set foreground color to Red.
    //     Ps = 9 2  -> Set foreground color to Green.
    //     Ps = 9 3  -> Set foreground color to Yellow.
    //     Ps = 9 4  -> Set foreground color to Blue.
    //     Ps = 9 5  -> Set foreground color to Magenta.
    //     Ps = 9 6  -> Set foreground color to Cyan.
    //     Ps = 9 7  -> Set foreground color to White.
    //     Ps = 1 0 0  -> Set background color to Black.
    //     Ps = 1 0 1  -> Set background color to Red.
    //     Ps = 1 0 2  -> Set background color to Green.
    //     Ps = 1 0 3  -> Set background color to Yellow.
    //     Ps = 1 0 4  -> Set background color to Blue.
    //     Ps = 1 0 5  -> Set background color to Magenta.
    //     Ps = 1 0 6  -> Set background color to Cyan.
    //     Ps = 1 0 7  -> Set background color to White.
    //
    //   If xterm is compiled with the 16-color support disabled, it
    //   supports the following, from rxvt:
    //     Ps = 1 0 0  -> Set foreground and background color to
    //     default.
    //
    //   If 88- or 256-color support is compiled, the following apply.
    //     Ps = 3 8  ; 5  ; Ps -> Set foreground color to the second
    //     Ps.
    //     Ps = 4 8  ; 5  ; Ps -> Set background color to the second
    //     Ps.
    //
    func cmdCharAttributes (_ pars: [Int], _ collect: cstring)
    {
        // Optimize a single SGR0.
        if pars.count == 1 && pars [0] == 0 {
            curAttr = CharData.defaultAttr
            return;
        }

        let parCount = pars.count
        //let empty = CharacterStyle (attribute: 0)
        var style = curAttr.style
        var fg = curAttr.fg
        var bg = curAttr.bg
        let def = CharData.defaultAttr

        var i = 0
        
        // Extended Colors
        //
        // There is an ambiguity here that is troublesome, to support extended
        // colors and colorspaces, two competing systems exists, one uses for example:
        // 38;2;R;G;B;NEXT - foreground true color
        // 38:2:ColorSpace:R:G:B:REST;NEXT - second style for the same
        //
        // The former apparently was a mistake, but we need to disambiguate the meaning
        // of pars, based on whether the above uses ":" or ";" we need that, because
        // the SGR is a collection of attributes, so after our parameter values, we
        // need to continue processing
        //
        //
        func parseExtendedColor () -> Attribute.Color? {
            var color: Attribute.Color? = nil
            let v = parser._parsTxt
            
            // If this is the new style
            if v.count > 2 && v [2] == UInt8(ascii: ":") {
                switch pars [i] {
                case 2: // RGB color
                    i += 1
                    // Color style, we ignore "ColorSpace"

                    if i+3 < parCount {
                        color = Attribute.Color.trueColor(
                              red: UInt8(min (pars [i+1], 255)),
                            green: UInt8(min (pars [i+2], 255)),
                             blue: UInt8(min (pars [i+3], 255)))
                        i += 4
                    }
                default:
                    break
                }
            } else if i < parCount {
                switch pars [i] {
                case 2: // RGB color
                    i += 1
                    if i+2 < parCount {
                        color = Attribute.Color.trueColor(
                              red: UInt8(min (pars [i], 255)),
                            green: UInt8(min (pars [i+1], 255)),
                             blue: UInt8(min (pars [i+2], 255)))
                        i += 3
                    }
                    
                case 3: // CMY color - not supported
                    break
                    
                case 4: // CMYK color - not supported
                    break
                    
                case 5: // indexed color
                    if i+1 < parCount {
                        color = Attribute.Color.ansi256(code: UInt8 (min (255, pars [i+1])))
                        i += 1
                    }
                    i += 1

                default:
                    break
                }
            }
            return color
        }
        
        while i < parCount {
            var p = pars [i]
            switch p {
            case 0:
                // default
                style = def.style
                fg = def.fg
                bg = def.bg
            case 1:
                // bold text
                style = [style, .bold]
            case 2:
                // dimmed text
                style = [style, .dim]
            case 3:
                // italic text
                style = [style, .italic]
            case 4:
                // underlined text
                style = [style, .underline]
            case 5:
                // blink
                style = [style, .blink]
            case 7:
                // inverse and positive
                // test with: echo -e '\e[31m\e[42mhello\e[7mworld\e[27mhi\e[m'
                style = [style, .inverse]
            case 8:
                // invisible
                style = [style, .invisible]
            case 9:
                style = [style, .crossedOut]
            case 21:
                // double underline
                break
            case 22:
                // not bold nor faint
                style.remove (.bold)
                style.remove (.dim)
            case 23:
                // not italic
                style.remove (.italic)
            case 24:
                // not underlined
                style.remove (.underline)
            case 25:
                // not blink
                style.remove (.blink)
            case 27:
                // not inverse
                style.remove (.inverse)
            case 28:
                // not invisible
                style.remove (.invisible)
            case 29:
                // not crossed out
                style.remove (.crossedOut)
            case 30...37:
                // fg color 8
                fg = Attribute.Color.ansi256(code: UInt8(p - 30))
            case 38:
                i += 1
                if let parsed = parseExtendedColor () {
                    fg = parsed
                }
                continue
            case 39:
                // reset fg
                fg = CharData.defaultAttr.fg
            case 40...47:
                // bg color 8
                bg = Attribute.Color.ansi256(code: UInt8(p - 40))
            case 48:
                i += 1
                if let parsed = parseExtendedColor() {
                    bg = parsed
                }
                continue
                
            case 49:
                // reset bg
                bg = CharData.defaultAttr.bg
            case 90...97:
                // fg color 16
                p += 8
                fg = Attribute.Color.ansi256(code: UInt8(p - 90))
            case 100...107:
                // bg color 16
                p += 8;
                bg = Attribute.Color.ansi256(code: UInt8(p - 100))
                
            case 58:
                // WezTerm extension:
                // https://wezterm.org/escape-sequences.html#csi-582-underline-color-rgb
                i += 1
                if pars.count > 2 {
                    let wcode = pars[1]
                    if wcode == 2 {
                        // underline color RGB
                        i += 4
                    } else if wcode == 6 {
                        // underline color RGBA
                        i += 5
                    }
                }
                
            default:
                print ("Unknown SGR attribute: \(p) \(pars)")
            }
            i += 1
        }
        curAttr = Attribute(fg: fg, bg: bg, style: style)
    }

    //
    //CSI Pm l  Reset Mode (RM).
    //    Ps = 2  -> Keyboard Action Mode (AM).
    //    Ps = 4  -> Replace Mode (IRM).
    //    Ps = 1 2  -> Send/receive (SRM).
    //    Ps = 2 0  -> Normal Linefeed (LNM).
    //CSI ? Pm l
    //  DEC Private Mode Reset (DECRST).
    //    Ps = 1  -> Normal Cursor Keys (DECCKM).
    //    Ps = 2  -> Designate VT52 mode (DECANM).
    //    Ps = 3  -> 80 Column Mode (DECCOLM).
    //    Ps = 4  -> Jump (Fast) Scroll (DECSCLM).
    //    Ps = 5  -> Normal Video (DECSCNM).
    //    Ps = 6  -> Normal Cursor Mode (DECOM).
    //    Ps = 7  -> No Wraparound Mode (DECAWM).
    //    Ps = 8  -> No Auto-repeat Keys (DECARM).
    //    Ps = 9  -> Don't send Mouse X & Y on button press.
    //    Ps = 1 0  -> Hide toolbar (rxvt).
    //    Ps = 1 2  -> Stop Blinking Cursor (att610).
    //    Ps = 1 8  -> Don't print form feed (DECPFF).
    //    Ps = 1 9  -> Limit print to scrolling region (DECPEX).
    //    Ps = 2 5  -> Hide Cursor (DECTCEM).
    //    Ps = 3 0  -> Don't show scrollbar (rxvt).
    //    Ps = 3 5  -> Disable font-shifting functions (rxvt).
    //    Ps = 4 0  -> Disallow 80 -> 132 Mode.
    //    Ps = 4 1  -> No more(1) fix (see curses resource).
    //    Ps = 4 2  -> Disable Nation Replacement Character sets (DEC-
    //    NRCM).
    //    Ps = 4 4  -> Turn Off Margin Bell.
    //    Ps = 4 5  -> No Reverse-wraparound Mode.
    //    Ps = 4 6  -> Stop Logging.  (This is normally disabled by a
    //    compile-time option).
    //    Ps = 4 7  -> Use Normal Screen Buffer.
    //    Ps = 6 6  -> Numeric keypad (DECNKM).
    //    Ps = 6 7  -> Backarrow key sends delete (DECBKM).
    //    Ps = 1 0 0 0  -> Don't send Mouse X & Y on button press and
    //    release.  See the section Mouse Tracking.
    //    Ps = 1 0 0 1  -> Don't use Hilite Mouse Tracking.
    //    Ps = 1 0 0 2  -> Don't use Cell Motion Mouse Tracking.
    //    Ps = 1 0 0 3  -> Don't use All Motion Mouse Tracking.
    //    Ps = 1 0 0 4  -> Don't send FocusIn/FocusOut events.
    //    Ps = 1 0 0 5  -> Disable Extended Mouse Mode.
    //    Ps = 1 0 1 0  -> Don't scroll to bottom on tty output
    //    (rxvt).
    //    Ps = 1 0 1 1  -> Don't scroll to bottom on key press (rxvt).
    //    Ps = 1 0 3 4  -> Don't interpret "meta" key.  (This disables
    //    the eightBitInput resource).
    //    Ps = 1 0 3 5  -> Disable special modifiers for Alt and Num-
    //    Lock keys.  (This disables the numLock resource).
    //    Ps = 1 0 3 6  -> Don't send ESC  when Meta modifies a key.
    //    (This disables the metaSendsEscape resource).
    //    Ps = 1 0 3 7  -> Send VT220 Remove from the editing-keypad
    //    Delete key.
    //    Ps = 1 0 3 9  -> Don't send ESC  when Alt modifies a key.
    //    (This disables the altSendsEscape resource).
    //    Ps = 1 0 4 0  -> Do not keep selection when not highlighted.
    //    (This disables the keepSelection resource).
    //    Ps = 1 0 4 1  -> Use the PRIMARY selection.  (This disables
    //    the selectToClipboard resource).
    //    Ps = 1 0 4 2  -> Disable Urgency window manager hint when
    //    Control-G is received.  (This disables the bellIsUrgent
    //    resource).
    //    Ps = 1 0 4 3  -> Disable raising of the window when Control-
    //    G is received.  (This disables the popOnBell resource).
    //    Ps = 1 0 4 7  -> Use Normal Screen Buffer, clearing screen
    //    first if in the Alternate Screen.  (This may be disabled by
    //    the titeInhibit resource).
    //    Ps = 1 0 4 8  -> Restore cursor as in DECRC.  (This may be
    //    disabled by the titeInhibit resource).
    //    Ps = 1 0 4 9  -> Use Normal Screen Buffer and restore cursor
    //    as in DECRC.  (This may be disabled by the titeInhibit
    //    resource).  This combines the effects of the 1 0 4 7  and 1 0
    //    4 8  modes.  Use this with terminfo-based applications rather
    //    than the 4 7  mode.
    //    Ps = 1 0 5 0  -> Reset terminfo/termcap function-key mode.
    //    Ps = 1 0 5 1  -> Reset Sun function-key mode.
    //    Ps = 1 0 5 2  -> Reset HP function-key mode.
    //    Ps = 1 0 5 3  -> Reset SCO function-key mode.
    //    Ps = 1 0 6 0  -> Reset legacy keyboard emulation (X11R6).
    //    Ps = 1 0 6 1  -> Reset keyboard emulation to Sun/PC style.
    //    Ps = 2 0 0 4  -> Reset bracketed paste mode.
    //
    func cmdResetMode (_ pars: [Int], _ collect: cstring)
    {
        if pars.count == 0 {
            return
        }

        if pars.count > 1 {
            for i in 0..<pars.count {
                resetMode (pars [i], collect)
            }
            return
        }
        resetMode (pars [0], collect)
    }

    func resetMode (_ par: Int, _ collect: cstring)
    {
        if collect == [] {
            switch (par) {
            case 2:
                // KAM mode - unlocks the keyboard, not supported
                break
            case 4:
                // IRM Insert/Replace Mode
                setInsertMode(false)
            case 20:
                // LNM—Line Feed/New Line Mode
                lineFeedMode = false
                break
            default:
                break
            }
        } else if collect == [UInt8 (ascii: "?")] {
            switch (par) {
            case 1:
                applicationCursor = false
            case 3:
                if allow80To132 {
                    // DECCOLM
                    resize (cols: 80, rows: rows)
                    tdel?.sizeChanged(source: self)
                    resetToInitialState()
                }
            case 4: // DECSCLM - Jump scroll mode
                smoothScroll = false
                break
            case 5:
                // Reset default color
                curAttr = CharData.defaultAttr
            case 6:
                // DECOM Reset
                originMode = false
            case 7:
                setWraparound(false)
            case 12:
                cursorBlink = false
            case 40:
                allow80To132 = false
            case 41:
                // Workaround not implemented 
                break
            case 45:
                reverseWraparound = false
            case 66:
                log ("Switching back to normal keypad.");
                applicationKeypad = false
                syncScrollArea ()
            case 69:
                // DECSLRM
                setMarginMode(false)
            case 9: // X10 Mouse
                mouseMode = .off
            case 1000: // vt200 mouse
                mouseMode = .off
            case 95: // DECNCSM - clear on DECCOLM changes
                // unsupported
                break
            case 1002: // button event mouse
                mouseMode = .off
            case 1003: // any event mouse
                mouseMode = .off
            case 1004: // send focusin/focusout events
                sendFocus = false
            case 1005: // utf8 ext mode mouse
                mouseProtocol = .x10
                mouseMode = .off
            case 1006: // sgr ext mode mouse
                mouseProtocol = .x10
                mouseMode = .off
            case 1015: // urxvt ext mode mouse
                mouseProtocol = .x10
                mouseMode = .off
            case 1016: // sgrPixel mode
                mouseProtocol = .x10
                mouseMode = .off
            case 25: // hide cursor
                hideCursor ()
            case 1048: // alt screen cursor
                cmdRestoreCursor ([], [])
            case 1034:
                // Terminal.app ignores this request, and keeps sending ESC+letter
                break
            case 1049: // alt screen buffer cursor
                fallthrough
            case 47: // normal screen buffer
                fallthrough
            case 1047: // normal screen buffer - clearing it first
                   // Ensure the selection manager has the correct buffer
                activateNormalBuffer(clearAlt: par == 1047 || par == 1049)
                if (par == 1049){
                    cmdRestoreCursor ([], [])
                }
                refresh (startRow: 0, endRow: rows - 1)
                syncScrollArea ()
                showCursor ()
                tdel?.bufferActivated(source: self)
                
            case 2004: // bracketed paste mode (https://cirw.in/blog/bracketed-paste)
                bracketedPasteMode = false
                break
            default:
                log ("Unhandled DEC Private Mode Reset (DECRST) with \(par)")
                break
            }
        }
    }

    //
    // CSI Pm h  Set Mode (SM).
    //     Ps = 2  -> Keyboard Action Mode (AM).
    //     Ps = 4  -> Insert Mode (IRM).
    //     Ps = 1 2  -> Send/receive (SRM).
    //     Ps = 2 0  -> Automatic Newline (LNM).
    // CSI ? Pm h
    //   DEC Private Mode Set (DECSET).
    //     Ps = 1  -> Application Cursor Keys (DECCKM).
    //     Ps = 2  -> Designate USASCII for character sets G0-G3
    //     (DECANM), and set VT100 mode.
    //     Ps = 3  -> 132 Column Mode (DECCOLM).
    //     Ps = 4  -> Smooth (Slow) Scroll (DECSCLM).
    //     Ps = 5  -> Reverse Video (DECSCNM).
    //     Ps = 6  -> Origin Mode (DECOM).
    //     Ps = 7  -> Wraparound Mode (DECAWM).
    //     Ps = 8  -> Auto-repeat Keys (DECARM).
    //     Ps = 9  -> Send Mouse X & Y on button press.  See the sec-
    //     tion Mouse Tracking.
    //     Ps = 1 0  -> Show toolbar (rxvt).
    //     Ps = 1 2  -> Start Blinking Cursor (att610).
    //     Ps = 1 8  -> Print form feed (DECPFF).
    //     Ps = 1 9  -> Set print extent to full screen (DECPEX).
    //     Ps = 2 5  -> Show Cursor (DECTCEM).
    //     Ps = 3 0  -> Show scrollbar (rxvt).
    //     Ps = 3 5  -> Enable font-shifting functions (rxvt).
    //     Ps = 3 8  -> Enter Tektronix Mode (DECTEK).
    //     Ps = 4 0  -> Allow 80 -> 132 Mode.
    //     Ps = 4 1  -> more(1) fix (see curses resource).
    //     Ps = 4 2  -> Enable Nation Replacement Character sets (DECN-
    //     RCM).
    //     Ps = 4 4  -> Turn On Margin Bell.
    //     Ps = 4 5  -> Reverse-wraparound Mode.
    //     Ps = 4 6  -> Start Logging.  This is normally disabled by a
    //     compile-time option.
    //     Ps = 4 7  -> Use Alternate Screen Buffer.  (This may be dis-
    //     abled by the titeInhibit resource).
    //     Ps = 6 6  -> Application keypad (DECNKM).
    //     Ps = 6 7  -> Backarrow key sends backspace (DECBKM).
    //     Ps = 1 0 0 0  -> Send Mouse X & Y on button press and
    //     release.  See the section Mouse Tracking.
    //     Ps = 1 0 0 1  -> Use Hilite Mouse Tracking.
    //     Ps = 1 0 0 2  -> Use Cell Motion Mouse Tracking.
    //     Ps = 1 0 0 3  -> Use All Motion Mouse Tracking.
    //     Ps = 1 0 0 4  -> Send FocusIn/FocusOut events.
    //     Ps = 1 0 0 5  -> Enable Extended Mouse Mode.
    //     Ps = 1 0 1 0  -> Scroll to bottom on tty output (rxvt).
    //     Ps = 1 0 1 1  -> Scroll to bottom on key press (rxvt).
    //     Ps = 1 0 3 4  -> Interpret "meta" key, sets eighth bit.
    //     (enables the eightBitInput resource).
    //     Ps = 1 0 3 5  -> Enable special modifiers for Alt and Num-
    //     Lock keys.  (This enables the numLock resource).
    //     Ps = 1 0 3 6  -> Send ESC   when Meta modifies a key.  (This
    //     enables the metaSendsEscape resource).
    //     Ps = 1 0 3 7  -> Send DEL from the editing-keypad Delete
    //     key.
    //     Ps = 1 0 3 9  -> Send ESC  when Alt modifies a key.  (This
    //     enables the altSendsEscape resource).
    //     Ps = 1 0 4 0  -> Keep selection even if not highlighted.
    //     (This enables the keepSelection resource).
    //     Ps = 1 0 4 1  -> Use the CLIPBOARD selection.  (This enables
    //     the selectToClipboard resource).
    //     Ps = 1 0 4 2  -> Enable Urgency window manager hint when
    //     Control-G is received.  (This enables the bellIsUrgent
    //     resource).
    //     Ps = 1 0 4 3  -> Enable raising of the window when Control-G
    //     is received.  (enables the popOnBell resource).
    //     Ps = 1 0 4 7  -> Use Alternate Screen Buffer.  (This may be
    //     disabled by the titeInhibit resource).
    //     Ps = 1 0 4 8  -> Save cursor as in DECSC.  (This may be dis-
    //     abled by the titeInhibit resource).
    //     Ps = 1 0 4 9  -> Save cursor as in DECSC and use Alternate
    //     Screen Buffer, clearing it first.  (This may be disabled by
    //     the titeInhibit resource).  This combines the effects of the 1
    //     0 4 7  and 1 0 4 8  modes.  Use this with terminfo-based
    //     applications rather than the 4 7  mode.
    //     Ps = 1 0 5 0  -> Set terminfo/termcap function-key mode.
    //     Ps = 1 0 5 1  -> Set Sun function-key mode.
    //     Ps = 1 0 5 2  -> Set HP function-key mode.
    //     Ps = 1 0 5 3  -> Set SCO function-key mode.
    //     Ps = 1 0 6 0  -> Set legacy keyboard emulation (X11R6).
    //     Ps = 1 0 6 1  -> Set VT220 keyboard emulation.
    //     Ps = 2 0 0 4  -> Set bracketed paste mode.
    // Modes:
    //   http: *vt100.net/docs/vt220-rm/chapter4.html
    //
    func cmdSetMode (_ pars: [Int], _ collect: cstring)
    {
        if pars.count == 0 {
            return
        }

        if pars.count > 1 {
            for i in 0..<pars.count {
                setMode (pars [i], collect)
            }
            return
        }
        setMode (pars [0], collect)
    }

    func setMode (_ par: Int, _ collect: cstring)
    {
        if (collect == []) {
            switch par {
            case 2:
                // KAM mode - unlocks the keyboard, I do not want to support it
                break
            case 4:
                // IRM Insert/Replace Mode
                // https://vt100.net/docs/vt510-rm/IRM.html
                setInsertMode(true)
//            case 12:
//                 SRM—Local Echo: Send/Receive Mode
//                 When implemented, hook up cmdDecRqm
//                break
            case 20:
                // Automatic New Line (LNM)
                lineFeedMode = true
                break;
            default:
                log ("Unhandled verbatim setMode with \(par) and \(collect)")
                break
            }
        } else if collect == [UInt8 (ascii: "?")] {
            switch par {
            case 1:
                applicationCursor = true
            case 2:
                setgCharset (0, charset: CharSets.defaultCharset)
                setgCharset (1, charset: CharSets.defaultCharset)
                setgCharset (2, charset: CharSets.defaultCharset)
                setgCharset (3, charset: CharSets.defaultCharset)
                // set VT100 mode here
                
            case 3: // DECCOLM - go to 132 col mode
                if allow80To132 {
                    resize (cols: 132, rows: rows)
                    resetToInitialState()
                    tdel?.sizeChanged(source: self)
                }
            case 4: // Smooth scroll mode
                smoothScroll = true
                break
            case 5:
                // Inverted colors
                curAttr = CharData.invertedAttr
            case 6:
                // DECOM Set
                originMode = true
            case 7:
                setWraparound(true)
            case 12:
                cursorBlink = true
                break;
            case 40:
                allow80To132 = true
            case 66:
                log ("Serial port requested application keypad.")
                applicationKeypad = true
                syncScrollArea ()
            case 9:
                // X10 Mouse
                mouseMode = .x10
            case 45: // Xterm Reverse Wrap-around
                // reverse wraparound can only be enabled if Auto-wrap is enabled (DECAWM)
                if wraparound {
                    reverseWraparound = true
                }
            case 69:
                // Enable left and right margin mode (DECLRMM),
                setMarginMode(true)
            case 95: // DECNCSM - clear on DECCOLM changes
                // unsupported
                break
            case 1000:
                // SET_VT200_HIGHLIGHT_MOUSE
                mouseMode = .vt200
            case 1002:
                // SET_BTN_EVENT_MOUSE
                mouseMode = .buttonEventTracking

            case 1003:
                // SET_ANY_EVENT_MOUSE
                mouseMode = .anyEvent

            case 1004: // send focusin/focusout events
                   // focusin: ^[[I
                   // focusout: ^[[O
                sendFocus = true
            case 1005:
                // utf8 ext mode mouse
                mouseProtocol = .utf8
                break;
            case 1006: // sgr ext mode mouse
                mouseProtocol = .sgr
            case 1015: // urxvt ext mode mouse
                mouseProtocol = .urxvt
            case 1016: // sgrPixel mode
                mouseProtocol = .sgrPixel
            case 25: // show cursor
                showCursor()
            case 63:
                // DECRLM - Cursor Right to Left Mode, not supported
                break
            case 1034:
                // Terminal.app ignores this request, and keeps sending ESC+letter
                // Given our UTF8 world, I do not think this is a worth encoding
                break
            case 1048: // alt screen cursor
                cmdSaveCursor ([], [])
            case 1049: // alt screen buffer cursor
                cmdSaveCursor ([], [])
                // FALL-THROUGH
                fallthrough
            case 47: // alt screen buffer
                fallthrough
            case 1047: // alt screen buffer
                activateAltBuffer (fillAttr: nil)
                refresh (startRow: 0, endRow: rows - 1)
                syncScrollArea ()
                showCursor ()
                tdel?.bufferActivated(source: self)
                
            case 2004: // bracketed paste mode (https://cirw.in/blog/bracketed-paste)
                // TODO: must implement bracketed paste mode
                bracketedPasteMode = true
            default:
                log ("Unhandled DEC Private Mode Set (DECSET) with \(par)")
                break;
            }
        } else {
            log ("Unhandled setMode (SM) with \(par) and \(collect)")
        }
        
    }


    //
    // CSI Ps g  Tab Clear (TBC).
    //     Ps = 0  -> Clear Current Column (default).
    //     Ps = 3  -> Clear All.
    // Potentially:
    //   Ps = 2  -> Clear Stops on Line.
    //   http://vt100.net/annarbor/aaa-ug/section6.html
    //
    func cmdTabClear (_ pars: [Int], _ collect: cstring)
    {
        let p = pars.count == 0 ? 0 : pars [0]
        if p == 0 {
            buffer.tabClear(pos: buffer.x)
        } else if (p == 3) {
            buffer.clearTabStops ()
        }
    }


    //
    // CSI Ps ; Ps f
    //   Horizontal and Vertical Position [row;column] (default =
    //   [1,1]) (HVP).
    //
    func cmdHVPosition (_ pars: [Int], _ collect: cstring)
    {
        var p = 1
        var q = 1
        if pars.count > 0 {
            p = max (pars [0], 1)
            if (pars.count > 1){
                q = max (pars [1], 1)
            }
        }
        
        buffer.y = p - 1 + (originMode ? buffer.scrollTop : 0)
        if buffer.y >= rows {
            buffer.y = rows - 1
        }
        
        buffer.x = q - 1 + (originMode && marginMode ? buffer.marginLeft : 0)
        if buffer.x >= cols {
            buffer.x = cols - 1
        }
    }

    //
    // CSI Pm e  Vertical Position Relative (VPR)
    //   [rows] (default = [row+1,column])
    // reuse CSI Ps B ?
    //
    func cmdVPositionRelative (_ pars: [Int], _ collect: cstring)
    {
        let p = max (pars.count == 0 ? 1 : pars [0], 1)
        let newY = buffer.y + p

        if newY >= rows {
            buffer.y = rows - 1
        } else {
            buffer.y = newY
        }

        // If the end of the line is hit, prevent this action from wrapping around to the next line.
        if buffer.x >= cols {
            buffer.x -= 1
        }
    }


    //
    // CSI Pm d  Vertical Position Absolute (VPA)
    //   [row] (default = [1,column])
    //
    func cmdLinePosAbsolute (_ pars: [Int], _ collect: cstring)
    {
        let p = max (pars.count == 0 ? 1 : pars [0], 1)

        if (p - 1 >= rows) {
            buffer.y = rows - 1
        } else {
            buffer.y = p - 1
        }
    }

    //
    // CSI Ps c  Send Device Attributes (Primary DA).
    //     Ps = 0  or omitted -> request attributes from terminal.  The
    //     response depends on the decTerminalID resource setting.
    //     -> CSI ? 1 ; 2 c  (``VT100 with Advanced Video Option'')
    //     -> CSI ? 1 ; 0 c  (``VT101 with No Options'')
    //     -> CSI ? 6 c  (``VT102'')
    //     -> CSI ? 6 0 ; 1 ; 2 ; 6 ; 8 ; 9 ; 1 5 ; c  (``VT220'')
    //   The VT100-style response parameters do not mean anything by
    //   themselves.  VT220 parameters do, telling the host what fea-
    //   tures the terminal supports:
    //     Ps = 1  -> 132-columns.
    //     Ps = 2  -> Printer.
    //     Ps = 4  -> Sixel graphics
    //     Ps = 6  -> Selective erase.
    //     Ps = 8  -> User-defined keys.
    //     Ps = 9  -> National replacement character sets.
    //     Ps = 1 5  -> Technical characters.
    //     Ps = 2 2  -> ANSI color, e.g., VT525.
    //     Ps = 2 9  -> ANSI text locator (i.e., DEC Locator mode).
    // CSI > Ps c
    //   Send Device Attributes (Secondary DA).
    //     Ps = 0  or omitted -> request the terminal's identification
    //     code.  The response depends on the decTerminalID resource set-
    //     ting.  It should apply only to VT220 and up, but xterm extends
    //     this to VT100.
    //     -> CSI  > Pp ; Pv ; Pc c
    //   where Pp denotes the terminal type
    //     Pp = 0  -> ``VT100''.
    //     Pp = 1  -> ``VT220''.
    //   and Pv is the firmware version (for xterm, this was originally
    //   the XFree86 patch number, starting with 95).  In a DEC termi-
    //   nal, Pc indicates the ROM cartridge registration number and is
    //   always zero.
    // More information:
    //   xterm/charproc.c - line 2012, for more information.
    //   vim responds with ^[[?0c or ^[[?1c after the terminal's response (?)
    //
    func cmdSendDeviceAttributes (_ pars: [Int], _ collect: cstring)
    {
        if pars.count > 0 && pars [0] > 0 {
            var safe = collect
            safe.append(0)
            log ("SendDeviceAttributes got \(pars) and \(String(cString: safe))")
            return
        }

        if collect == [UInt8 (ascii: ">")] || collect == [UInt8 (ascii: ">"), UInt8 (ascii: "0")] {
            // DA2 Secondary Device Attributes
            if pars.count == 0 || pars [0] == 0 {
                let vt525 = 65 // we identified as a vt525
                let kbd = 1 // PC-style keyboard
                sendResponse(cc.CSI, ">\(vt525);20;\(kbd)c")
                return
            }
            log ("Got a CSI > c with an unknown set of argument")
            return
        }
        
        // We should use a terminal emulation level, and not rely on the TERM name
        // for now, "xterm" as a part of the name surfaces all the capabilities.
        let name = options.termName
        if collect == [] {
            let termVt525 = 65
            let sixel = options.enableSixelReported ? ";4" : ""
            let cols132 = 1
            let printer = 2
            let decsera = 6
            let terminalStateInterrogation = 17
            let horizontalScrolling = 21
            let ansiColor = 22
            let rectangularEditing = 28
            
            // Send Device Attributes (Primary DA).1
            if name.hasPrefix("xterm") {
                sendResponse (cc.CSI, "?\(termVt525)\(sixel);\(cols132);\(printer);\(decsera);\(horizontalScrolling);\(ansiColor);\(terminalStateInterrogation);\(rectangularEditing)c")
            } else if name.hasPrefix("screen") || name.hasPrefix ("rxvt-unicode") {
                sendResponse (cc.CSI, "?\(cols132);\(printer)c")
            } else if name.hasPrefix ("linux") {
                sendResponse (cc.CSI, "?\(decsera)c")
            }
        } else if collect.count == 1 && collect [0] == UInt8 (ascii: ">") {
            // xterm and urxvt
            // seem to spit this
            // out around ~370 times (?).
            if name.hasPrefix ("xterm") {
                sendResponse (cc.CSI, ">0;276;0c")
            } else if name.hasPrefix ("rxvt-unicode") {
                sendResponse (cc.CSI, ">85;95;0c")
            } else if name.hasPrefix ("linux") {
                // not supported by linux console.
                // linux console echoes parameters.
                sendResponse ("\(pars[0])c")
            } else if name.hasPrefix ("screen") {
                sendResponse (cc.CSI, ">83;40003;0c")
            }
        }
    }


    //
    // CSI Ps b  Repeat the preceding graphic character Ps times (REP).
    //
    func cmdRepeatPrecedingCharacter (_ pars: [Int], _ collect: cstring)
    {
        // Maximum repeat, to avoid a denial of service
        let maxRepeat = cols*rows*2
        let p = min (maxRepeat, max (pars.count == 0 ? 1 : pars [0], 1))
        let line = buffer.lines [buffer.yBase + buffer.y]
        let chData = buffer.x - 1 < 0 ? CharData (attribute: CharData.defaultAttr) : line [buffer.x - 1]
        
        for _ in 0..<p {
            insertCharacter(chData)
        }
    }

    //
    //CSI Pm a  Character Position Relative
    //  [columns] (default = [row,col+1]) (HPR)
    //reuse CSI Ps C ?
    //
    func cmdHPositionRelative (_ pars: [Int], _ collect: cstring)
    {
        let p = max (pars.count == 0 ? 1 : pars [0], 1)
        
        buffer.x += p
        if buffer.x >= cols {
            buffer.x = cols - 1
        }
    }

    //
    // CSI Pm `  Character Position Absolute
    //   [column] (default = [row,1]) (HPA).
    //
    func cmdCharPosAbsolute (_ pars: [Int], _ collect: cstring)
    {
        let p = max (pars.count == 0 ? 1 : pars [0], 1)

        buffer.x = p - 1
        if buffer.x >= cols {
            buffer.x = cols - 1
        }
    }

    //
    //CSI Ps Z  Cursor Backward Tabulation Ps tab stops (default = 1) (CBT).
    //
    func cmdCursorBackwardTab (_ pars: [Int], _ collect: cstring)
    {
        if buffer.x > cols {
            return
        }
        let p = min (buffer.cols, max (pars.count == 0 ? 1 : pars [0], 1))

        for _ in 0..<p {
            buffer.x = buffer.previousTabStop ()
        }
    }

    //
    // CSI Ps X
    // Erase Ps Character(s) (default = 1) (ECH).
    //
    func cmdEraseChars (_ pars: [Int], _ collect: cstring)
    {
        let p = max (pars.count == 0 ? 1 : pars [0], 1)

        buffer.lines [buffer.y + buffer.yBase].replaceCells (
            start: buffer.x,
            end: buffer.x + p,
            fillData: CharData (attribute:  eraseAttr ()))
    }

    func csiT (_ pars: [Int], _ collect: cstring)
    {
        if collect.count == 0 {
            cmdScrollDown(pars)
        } else if collect == [UInt8 (ascii: ">")] {
            cmdXtermTitleModeReset(pars)
        }
    }
    //
    // CSI Ps T  Scroll down Ps lines (default = 1) (SD).
    //
    func cmdScrollDown (_ pars: [Int])
    {
        let p = min (max (pars.count == 0 ? 1 : pars [0], 1), rows)
        let da = CharData.defaultAttr

        let row = buffer.scrollTop + buffer.yBase

        let columnCount = buffer.marginRight-buffer.marginLeft+1
        let rowCount = buffer.scrollBottom-buffer.scrollTop
        for _ in 0..<p {
            for i in (0..<rowCount).reversed() {
                let src = buffer.lines [row+i]
                let dst = buffer.lines [row+i+1]
                
                dst.copyFrom(src, srcCol: buffer.marginLeft, dstCol: buffer.marginLeft, len: columnCount)
            }
            let last = buffer.lines [row]
            last.fill (with: CharData (attribute: da), atCol: buffer.marginLeft, len: columnCount)
        }
        // this.maxRange();
        updateRange (startLine: buffer.scrollTop, endLine: buffer.scrollBottom)
    }

    //
    // CSI Ps S  Scroll up Ps lines (default = 1) (SU).
    //
    func cmdScrollUp (_ pars: [Int], _ collect: cstring)
    {
        let p = min (rows*2, max (pars.count == 0 ? 1 : pars [0], 1))
        let da = CharData.defaultAttr

        if marginMode {
            let row = buffer.scrollTop + buffer.yBase

            let columnCount = buffer.marginRight-buffer.marginLeft+1
            let rowCount = buffer.scrollBottom-buffer.scrollTop
            for _ in 0..<p {
                for i in 0..<(rowCount) {
                    let src = buffer.lines [row+i+1]
                    let dst = buffer.lines [row+i]
                    
                    dst.copyFrom(src, srcCol: buffer.marginLeft, dstCol: buffer.marginLeft, len: columnCount)
                }
                let last = buffer.lines [row+rowCount]
                last.fill (with: CharData (attribute: da), atCol: buffer.marginLeft, len: columnCount)
            }
        } else {
            for _ in 0..<p {
                buffer.lines.splice (start: buffer.yBase + buffer.scrollTop, deleteCount: 1,
                                     items: [], change: { line in updateRange (line)})
                buffer.lines.splice (start: buffer.yBase + buffer.scrollBottom, deleteCount: 0,
                                     items: [buffer.getBlankLine (attribute: da)],
                                     change: { line in updateRange (line) })
            }
        }
        // this.maxRange();
        updateRange (startLine: buffer.scrollTop, endLine: buffer.scrollBottom)
    }

    //
    // CSI Ps P
    // Delete Ps Character(s) (default = 1) (DCH).
    //
    func cmdDeleteChars (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        var p = max (pars.count == 0 ? 1 : pars [0], 1)
        
        if marginMode {
            if buffer.x < buffer.marginLeft || buffer.x > buffer.marginRight {
                return
            }
            if buffer.x + p > buffer.marginRight {
                p = buffer.marginRight - buffer.x + 1
            }
        }
        // buffer.x = buffer.cols is a special case on the edge, we do not delete columns in that boundary
        if buffer.x == buffer.cols {
            return
        }
        buffer.lines [buffer.y + buffer.yBase].deleteCells (
            pos: buffer.x, n: p, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: CharData (attribute: eraseAttr ()))
        
        updateRange (buffer.y)
    }

    //
    // CSI Ps M
    // Delete Ps Line(s) (default = 1) (DL).
    //
    func cmdDeleteLines (_ pars: [Int], _ collect: cstring)
    {
        restrictCursor()
        let buffer = self.buffer
        // No point deleting more lines than the available rows, prevents
        // a denial of service caused by very large numbers passed here
        let p = min (buffer.rows+1, max (pars.count == 0 ? 1 : pars [0], 1))
        let row = buffer.y + buffer.yBase
        var j = rows - 1 - buffer.scrollBottom
        j = rows - 1 + buffer.yBase - j
        let ea = eraseAttr ()
        
        if marginMode {
            if buffer.x >= buffer.marginLeft && buffer.x <= buffer.marginRight {
                let columnCount = buffer.marginRight-buffer.marginLeft+1
                let rowCount = buffer.scrollBottom-buffer.scrollTop
                for _ in 0..<p {
                    for i in 0..<(rowCount) {
                        let src = buffer.lines [row+i+1]
                        let dst = buffer.lines [row+i]
                        
                        dst.copyFrom(src, srcCol: buffer.marginLeft, dstCol: buffer.marginLeft, len: columnCount)
                    }
                    
                    let last = buffer.lines [row+rowCount]
                    last.fill (with: CharData (attribute: ea), atCol: buffer.marginLeft, len: columnCount)
                }
            }
        } else {
            if buffer.y >= buffer.scrollTop && buffer.y <= buffer.scrollBottom {
                for _ in 0..<p {
                    // test: echo -e '\e[44m\e[1M\e[0m'
                    // blankLine(true) - xterm/linux behavior
                    buffer.lines.splice (start: row, deleteCount: 1, items: [], change: { line in updateRange (line)})
                    buffer.lines.splice (start: j, deleteCount: 0,
                                         items: [buffer.getBlankLine (attribute: ea)],
                                         change: { line in updateRange (line)})
                }
            }
        }
        
        // this.maxRange();
        updateRange (startLine: buffer.y, endLine: buffer.scrollBottom)
    }

    //
    // CSI Ps ' ~
    // Delete Ps Column(s) (default = 1) (DECDC), VT420 and up.
    //
    // @vt: #Y CSI DECDC "Delete Columns"  "CSI Ps ' ~"  "Delete `Ps` columns at cursor position."
    // DECDC deletes `Ps` times columns at the cursor position for all lines with the scroll margins,
    // moving content to the left. Blank columns are added at the right margin.
    // DECDC has no effect outside the scrolling margins.

    func cmdDeleteColumns (_ pars: [Int], _ collect: cstring)
    {
        let buffer = self.buffer
        if buffer.y > buffer.scrollBottom || buffer.y < buffer.scrollTop {
            return
        }
        // buffer.x = buffer.cols is a special case on the edge, we do not delete columns in that boundary
        if buffer.x == buffer.cols {
            return
        }
        if marginMode {
            if buffer.x < buffer.marginLeft || buffer.x > buffer.marginRight {
                return
            }
        }

        let p = max (pars.count == 0 ? 1 : pars [0], 1)
        
        for y in buffer.scrollTop...buffer.scrollBottom {
            let line = buffer.lines [buffer.yBase + y]
            line.deleteCells(pos: buffer.x, n: p, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: buffer.getNullCell(attribute: eraseAttr()))
            line.isWrapped = false
        }
        updateRange (startLine: buffer.scrollTop, endLine: buffer.scrollBottom)
    }


    //
    // Helper method to reset cells in a terminal row.
    // The cell gets replaced with the eraseChar of the terminal and the isWrapped property is set to false.
    // @param y row index
    //
    func resetBufferLine (y: Int)
    {
        eraseInBufferLine (y: y, start: 0, end: cols, clearWrap: true, clearRenderMode: true)
        updateRange(y)
    }

    /**
     * Sends the provided text to the connected backend
     */
    public func sendResponse (text: String)
    {
        tdel?.send (source: self, data: ([UInt8] (text.utf8))[...])
    }
    
    /**
     * Sends the provided text to the connected backend, takes a variable list of arguments
     * that could be either [UInt8], Strings, or a single UInt8 value.
     */
    public func sendResponse (_ items: Any ...)
    {
        var buffer: [UInt8] = []
        
        for item in items {
            if let arr = item as? [UInt8] {
                buffer.append(contentsOf: arr)
            } else if let str = item as? String {
                buffer.append (contentsOf: [UInt8] (str.utf8))
            } else if let c = item as? UInt8 {
                buffer.append (c)
            } else {
                log ("Do not know how to handle type \(item)")
            }
        }
        tdel?.send (source: self, data: buffer[...])
    }
    
#if DEBUG
    public var silentLog = false
#else
    public var silentLog = true
#endif
    
    func error (_ text: String)
    {
        if !silentLog {
            print("Error: \(text)")
        }
    }
    
    func log (_ text: String)
    {
        if !silentLog {
            print("Info: \(text)")
        }
    }
    
    /**
     * Processes the provided byte-array coming from the host, interprets them and
     * updates the screen state accordingly.
     */
    public func feed (byteArray: [UInt8])
    {
        parse (buffer: byteArray[...])
    }
    
    /**
     * Processes the provided byte-array coming from the host, interprets them and
     * updates the screen state accordingly.
     */
    public func feed (text: String)
    {
        parse (buffer: ([UInt8] (text.utf8))[...])
    }

    /**
     * Processes the provided byte-array coming from the host, interprets them and
     * updates the screen state accordingly.
     */
    public func feed (buffer: ArraySlice<UInt8>)
    {
        parse (buffer: buffer)
    }

    /**
     * Processes the provided byte-array coming from the host, interprets them and
     * updates the screen state accordingly.
     */
    public func parse (buffer: ArraySlice<UInt8>)
    {
        parser.parse(data: buffer)
    }
     
    /**
     * Registers the given line as requiring to be updated by the front-end engine
     *
     * The front-end engine should call `getUpdateRange` to
     * determine which region in the screen needs to be redrawn.   This method adds the specified
     * line to the range of modified lines
     *
     * Scrolling tells if this was just issued as part of scrolling which we don't register for the
     * scroll-invariant update ranges.
     */
    func updateRange (_ y: Int, scrolling: Bool = false)
    {        
        if !scrolling {
            let effectiveY = buffer.yDisp + y
            if effectiveY >= 0 {
                if effectiveY < scrollInvariantRefreshStart {
                    scrollInvariantRefreshStart = effectiveY
                }
                if effectiveY > scrollInvariantRefreshEnd {
                    scrollInvariantRefreshEnd = effectiveY
                }
            }
        }
        
        if y >= 0 {
            if y < refreshStart {
                refreshStart = y
            }
            if y > refreshEnd {
                refreshEnd = y
            }
        }
    }
    
    func updateRange (startLine: Int, endLine: Int, scrolling: Bool = false)
    {
        updateRange (startLine, scrolling: scrolling)
        updateRange (endLine, scrolling: scrolling)
    }
    
    public func updateFullScreen ()
    {
        refreshStart = 0
        refreshEnd = rows
        
        scrollInvariantRefreshStart = buffer.yDisp
        scrollInvariantRefreshEnd = buffer.yDisp + rows
    }
    
    /**
     * Returns the starting and ending lines that need to be redrawn, or nil
     * if no part of the screen needs to be updated.   Alternatively, you can
     * get a Set<Int> with the changed lines by calling `changedLines()`.
     *
     * UI toolkits should call `clearUpdateRange` to reset these changes
     * after they have used this information, so that new changes only reflect
     * the actual changes.
     */
    public func getUpdateRange () -> (startY: Int, endY: Int)?
    {
        if refreshEnd == -1 && refreshStart == Int.max {
            //print ("Emtpy update range")
            return nil
        }
        //print ("Update: \(refreshStart) \(refreshEnd)")
        return (refreshStart, refreshEnd)
    }

    /**
     * Check for payload identifiers that are not in use and stop retaining their payload,
     * to avoid accumulting memory for images and URLs that are no longer visible or
     * available by scrolling.
     */
    public func garbageCollectPayload() {
        // stop right away if there is nothing to collect
        if TinyAtom.lastCollected == TinyAtom.lastUsed {
            return
        }
        
        // check all atoms used in both buffers
        var used = Set<UInt16>()
        for buffer in [normalBuffer, altBuffer] {
            // TODO use a better system than this ugly nest
            for line in buffer.lines.getArray() {
                if let array = line?.getData() {
                    for data in array {
                        let code = data.payload.code
                        if code > 0 {
                            used.insert(code)
                        }
                    }
                }
            }
        }
        
        // since we create atoms in order we expect them to run out of use
        // in order as well and stop with first atom that is still in use
        for code in UInt16(TinyAtom.lastCollected + 1)...UInt16(TinyAtom.lastUsed) {
            if used.contains(code) {
                // code still in use
                break
            }
            
            TinyAtom.lastCollected = Int(code)
            TinyAtom.release(code: code)
        }
    }
    
    /**
     * Returns the starting and ending lines that need to be redrawn, or nil
     * if no part of the screen needs to be updated.
     *
     * This is different from getUpdateRange() in that lines are from start of scroll back,
     * not what the terminal has visible right now.
     */
    public func getScrollInvariantUpdateRange () -> (startY: Int, endY: Int)?
    {
        if scrollInvariantRefreshEnd == -1 && scrollInvariantRefreshStart == Int.max {
            //print ("Emtpy update range")
            return nil
        }
        //print ("Update: \(scrollInvariantRefreshStart) \(scrollInvariantRefreshEnd)")
        return (scrollInvariantRefreshStart, scrollInvariantRefreshEnd)
    }
    
    /**
     * Clears the state of the pending display redraw region as well as the dirtyLines set.
     */
    public func clearUpdateRange ()
    {
        refreshStart = Int.max
        refreshEnd = -1
        
        scrollInvariantRefreshStart = Int.max
        scrollInvariantRefreshEnd = -1
    }
    
    /**
     * Zero-based (row, column) of cursor location relative to visible part of display.
     * Returns: a tuple, where the first element contains the column (x) and the second the row (y) where the cursor is.
     */
    public func getCursorLocation() -> (x: Int, y: Int) {
        return (buffer.x, buffer.y)
    }
    
    /**
     * Returns the uppermost visible row on the terminal buffer
     */
    public func getTopVisibleRow() -> Int {
        return buffer.yDisp
    }
    
    // ESC c Full Reset (RIS)
    /// This performs a full reset of the terminal, like a soft reset, but additionally resets the buffer conents and scroll area.
    /// for a soft reset see `softReset`
    public func resetToInitialState ()
    {
        options.rows = rows
        options.cols = cols
        let savedCursorHidden = cursorHidden
        setup (isReset: true)
        cursorHidden = savedCursorHidden
        refresh (startRow: 0, endRow: rows-1)
        syncScrollArea ()
    }

    // Support for:
    // ESC 6 Back Index (DECBI) and
    // ESC 9 Forward Index (DECFI)
    func columnIndex (back: Bool)
    {
        let buffer = self.buffer
        let x = buffer.x
        let leftMargin = buffer.marginLeft
        if back {
            if x == leftMargin {
                columnScroll (back: back, at: x)
            } else {
                cursorBackward(count: 1)
            }
        } else {
            let rightMargin = buffer.marginRight
            if x == rightMargin  {
                columnScroll (back: back, at: leftMargin)
            } else if x == buffer.cols {
                // on the boundaries, we ignore, test_DECFI_WholeScreenScrolls
            } else {
                cursorForward(count: 1)
            }
        }
    }
    
    func columnScroll (back: Bool, at: Int)
    {
        if buffer.y < buffer.scrollTop || buffer.y > buffer.scrollBottom || buffer.x < buffer.marginLeft || buffer.x > buffer.marginRight {
            return
        }
        for y in buffer.scrollTop...buffer.scrollBottom {
            let line = buffer.lines [buffer.yBase + y]
            if back {
                line.insertCells(pos: at, n: 1, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: buffer.getNullCell())
            } else {
                line.deleteCells(pos: at, n: 1, rightMargin: marginMode ? buffer.marginRight : cols-1, fillData: buffer.getNullCell(attribute: eraseAttr()))
            }
            //line.isWrapped = false
        }
        updateRange (buffer.scrollTop)
        updateRange (buffer.scrollBottom)
    }
    
    // ESC D Index (Index is 0x84) - IND
    func cmdIndex ()
    {
        restrictCursor()
        
        let buffer = self.buffer
        let newY = buffer.y + 1
        if newY > buffer.scrollBottom {
            scroll ()
        } else {
            buffer.y = newY
        }
        // If the end of the line is hit, prevent this action from wrapping around to the next line
        if buffer.x > cols {
            buffer.x -= 1
        }
    }
    
    var blankLine: BufferLine = BufferLine(cols: 0)
    
    public func scroll (isWrapped: Bool = false)
    {
        let buffer = self.buffer
        var newLine = blankLine
        if newLine.count != cols || newLine [0].attribute != eraseAttr () {
            newLine = buffer.getBlankLine (attribute: eraseAttr (), isWrapped: isWrapped)
            blankLine = newLine
        }
        newLine.isWrapped = isWrapped

        let topRow = buffer.yBase + buffer.scrollTop
        let bottomRow = buffer.yBase + buffer.scrollBottom

        if buffer.scrollTop == 0 {
            // Determine whether the buffer is going to be trimmed after insertion.
            let willBufferBeTrimmed = buffer.lines.isFull

            // Insert the line using the fastest method
            if bottomRow == buffer.lines.count - 1 {
                if willBufferBeTrimmed {
                    buffer.lines.recycle ()
                } else {
                    buffer.lines.push (BufferLine (from: newLine))
                }
            } else {
                buffer.lines.splice (start: bottomRow + 1, deleteCount: 0,
                                     items: [BufferLine (from: newLine)],
                                     change: { line in updateRange (line)})
            }

            // Only adjust ybase and ydisp when the buffer is not trimmed
            if !willBufferBeTrimmed {
                buffer.yBase += 1
                // Only scroll the ydisp with ybase if the user has not scrolled up
                if !userScrolling {
                    buffer.yDisp += 1
                }
            } else {
                if buffer.hasScrollback {
                    buffer.linesTop += 1
                }
                
                // When the buffer is full and the user has scrolled up, keep the text
                // stable unless ydisp is right at the top
                if userScrolling {
                    buffer.yDisp = max (buffer.yDisp - 1, 0)
                }
            }
        } else {
            // scrollTop is non-zero which means no line will be going to the
            // scrollback, instead we can just shift them in-place.
            let scrollRegionHeight = bottomRow - topRow + 1 /*as it's zero-based*/
            if scrollRegionHeight > 1 {
                if !buffer.lines.shiftElements (start: topRow + 1, count: scrollRegionHeight - 1, offset: -1) {
                    print ("Assertion on scroll, state was: bottomRow=\(bottomRow) topRow=\(topRow) yDisp=\(buffer.yDisp) linesTop=\(buffer.linesTop) isAlternate=\(isCurrentBufferAlternate)")
                }
            }
            buffer.lines [bottomRow] = BufferLine (from: newLine)
        }

        // Move the viewport to the bottom of the buffer unless the user is
        // scrolling.
        if !userScrolling {
            buffer.yDisp = buffer.yBase
        }

        //buffer.dump ()
        // Flag rows that need updating
        updateRange (buffer.scrollTop, scrolling: true)
        updateRange (buffer.scrollBottom, scrolling: true)
        
        if !buffer.hasScrollback {
            updateRange(startLine: buffer.scrollTop, endLine: buffer.scrollBottom)
        }

        /**
         * This event is emitted whenever the terminal is scrolled.
         * The one parameter passed is the new y display position.
         *
         * @event scroll
         */
        tdel?.scrolled(source: self, yDisp: buffer.yDisp)
    }
        
    public func emitLineFeed ()
    {
        tdel?.linefeed(source: self)
    }
    
    //
    // ESC n
    // ESC o
    // ESC |
    // ESC }
    // ESC ~
    //   DEC mnemonic: LS (https://vt100.net/docs/vt510-rm/LS.html)
    //   When you use a locking shift, the character set remains in GL or GR until
    //   you use another locking shift. (partly supported)
    //
    func setgLevel (_ v: UInt8)
    {
        gLevel = v
        if let cs = CharSets.all [v] {
            charset = cs
        } else {
            charset = nil
        }
    }
    
    //
    // ESC % @
    // ESC % G
    //   Select default character set. UTF-8 is not supported (string are unicode anyways)
    //   therefore ESC % G does the same.
    //
    func cmdSelectDefaultCharset ()
    {
        setgLevel (0)
        setgCharset (0, charset: CharSets.defaultCharset)
    }

    //
    // ESC c
    //   DEC mnemonic: RIS (https://vt100.net/docs/vt510-rm/RIS.html)
    //   Reset to initial state.
    //
    func cmdReset ()
    {
            parser.reset ()
            resetToInitialState ()
    }
            
    //
    // ESC >
    //   DEC mnemonic: DECKPNM (https://vt100.net/docs/vt510-rm/DECKPNM.html)
    //   Enables the keypad to send numeric characters to the host.
    //
    func cmdKeypadNumericMode ()
    {
            applicationKeypad = false
            syncScrollArea ()
    }
                    
    //
    // ESC =
    //   DEC mnemonic: DECKPAM (https://vt100.net/docs/vt510-rm/DECKPAM.html)
    //   Enables the numeric keypad to send application sequences to the host.
    //
    func cmdKeypadApplicationMode ()
    {
            applicationKeypad = true
            syncScrollArea ()
    }

    func eraseAttr () -> Attribute
    {
        Attribute (fg: CharData.defaultAttr.fg, bg: curAttr.bg, style: CharData.defaultAttr.style)
    }
    
    func setgCharset (_ v: UInt8, charset: [UInt8: String]?)
    {
        CharSets.all [v] = charset
        if gLevel == v {
            self.charset = charset
        }
    }
    
    public func resize (cols: Int, rows: Int)
    {
        let newCols = max (cols, MINIMUM_COLS)
        let newRows = max (rows, MINIMUM_ROWS)
        if newCols == self.cols && newRows == self.rows {
            return
        }
        let oldCols = self.cols
        resizeBuffers(newColumns: newCols, newRows: newRows)
        self.cols = newCols
        self.rows = newRows
        options.cols = newCols
        options.rows = newRows
        normalBuffer.setupTabStops (index: oldCols, tabStopWidth: tabStopWidth)
        altBuffer.setupTabStops (index: oldCols, tabStopWidth: tabStopWidth)
        refresh (startRow: 0, endRow: self.rows - 1)
    }
    
    func syncScrollArea ()
    {
        // This should call the viewport sync-scroll-area
    }

    /**
     * Registers that the region between startRow and endRow was modified and needs to be updated by the
     */
    public func refresh (startRow: Int, endRow: Int)
    {
        // TO BE HONEST - This probably should not be called directly,
        // instead the view shoudl after feeding data, determine if there is a need
        // to refresh based on the parameters provided for refresh ranges, and then
        // update, to avoid the backend rtiggering this multiple times.

        updateRange (startLine: startRow, endLine: endRow)
    }
    
    public func showCursor ()
    {
        if cursorHidden == false {
            return
        }
        cursorHidden = false
        //refresh (startRow: buffer.y, endRow: buffer.y)
        tdel?.showCursor (source: self)
    }
    
    public func hideCursor ()
    {
        if cursorHidden {
            return
        }
        cursorHidden = true
        tdel?.hideCursor(source: self)
    }

    // Encode button and position to characters
    func encodeMouseUtf (data: inout [UInt8], ch: Int)
    {
        if ch == 2047 {
            data.append(0)
            return
        }
        if ch < 127 {
            data.append (UInt8(ch))
        } else {
            let rc = ch > 2047 ? 2047 : ch
            data.append (0xc0 | (UInt8 (rc >> 6)))
            data.append (0x80 | (UInt8 (rc & 0x3f)))
        }
    }
    
    /**
     * Encodes the button action in the format expected by the client
     * - Parameter button: The button to encode
     * - Parameter release: `true` if this is a mouse release event
     * - Parameter shift: `true` if the shift key is pressed
     * - Parameter meta: `true` if the meta/alt key is pressed
     * - Parameter control: `true` if the control key is pressed
     * - Returns: the encoded value
     */
    public func encodeButton (button: Int, release: Bool, shift: Bool, meta: Bool, control: Bool) -> Int
    {
        var value: Int

        if release {
            value = 3
        } else {
            switch (button) {
            case 0:
                value = 0
            case 1:
                value = 1
            case 2:
                value = 2
            case 4:
                value = 64
            case 5:
                value = 65
            default:
                value = 0
            }
        }
        if mouseMode.sendsModifiers() {
            if shift {
                value |= 4
            }
            if meta {
                value |= 8
            }
            if control {
                value |= 16
            }
        }
        return value
    }
    
    public func sendEvent (buttonFlags: Int, x: Int, y: Int) {
      sendEvent(buttonFlags: buttonFlags, x: x, y: y, pixelX: x, pixelY: y)
    }
    
    /**
     * Sends a mouse event for a specific button at the specific location
     * - Parameter buttonFlags: Button flags encoded in Cb mode.
     * - Parameter x: X coordinate for the event
     * - Parameter y: Y coordinate for the event
     */
    public func sendEvent (buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int)
    {
        //print ("got \(mouseProtocol)")
        switch mouseProtocol {
        case .x10:
            sendResponse(cc.CSI, "M", [UInt8(buttonFlags+32), min (UInt8(255), UInt8(32 + x+1)), min (UInt8(255), UInt8(32+y+1))])
        case .sgr:
            let bflags : Int = ((buttonFlags & 3) == 3) ? (buttonFlags & ~3) : buttonFlags
            let m = ((buttonFlags & 3) == 3) ? "m" : "M"
            sendResponse(cc.CSI, "<\(bflags);\(x+1);\(y+1)\(m)")
        case .sgrPixel:
            let bflags : Int = ((buttonFlags & 3) == 3) ? (buttonFlags & ~3) : buttonFlags
            let m = ((buttonFlags & 3) == 3) ? "m" : "M"
            print ("\(pixelX);\(pixelY)")
            sendResponse(cc.CSI, "<\(bflags);\(pixelX);\(pixelY)\(m)")
            
        case .urxvt:
            sendResponse(cc.CSI, "\(buttonFlags+32);\(x+1);\(y+1)M");
        case .utf8:
            var buffer: [UInt8] = [UInt8 (ascii: "M")]
            encodeMouseUtf(data: &buffer, ch: buttonFlags+32)
            encodeMouseUtf (data: &buffer, ch: x+33)
            encodeMouseUtf (data: &buffer, ch: y+33)
            sendResponse(cc.CSI, buffer)
        }
    }
    
    /**
     * Sends a mouse motion event for a specific button at the specific location
     * - Parameter buttonFlags: Button flags encoded in Cb mode.
     * - Parameter x: X coordinate for the event
     * - Parameter y: Y coordinate for the event
     */
    public func sendMotion (buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int)
    {
        sendEvent(buttonFlags: buttonFlags+32, x: x, y: y, pixelX: pixelX, pixelY: pixelY)
    }
    
    static var matchColorCache : [Int:Int] = [:]
    func matchColor (_ r1: Int, _ g1: Int, _ b1: Int) -> Int32
    {
        // TODO
        abort ()
    }
    
    var terminalTitle: String = ""              // The Xterm terminal title
    var iconTitle: String = ""                  // The Xterm minimized window title
    var terminalTitleStack: [String] = []
    var terminalIconStack: [String] = []
    
    public func setTitle (text: String)
    {
        terminalTitle = text
        tdel?.setTerminalTitle(source: self, title: text)
    }

    public func setIconTitle (text: String)
    {
        iconTitle = text
        tdel?.setTerminalIconTitle(source: self, title: text)
    }

    func reverseIndex ()
    {
        let buffer = self.buffer
        restrictCursor()
        if buffer.y == buffer.scrollTop {
            // possibly move the code below to term.reverseScroll()
            // test: echo -ne '\e[1;1H\e[44m\eM\e[0m'
            // blankLine(true) is xterm/linux behavior
            let scrollRegionHeight = buffer.scrollBottom - buffer.scrollTop
            if !buffer.lines.shiftElements (start: buffer.y + buffer.yBase, count: scrollRegionHeight, offset: 1) {
                print ("Assertion on reverseIndex, state was: y=\(buffer.y) scrollTop=\(buffer.scrollTop)  yDisp=\(buffer.yDisp) linesTop=\(buffer.linesTop) isAlternate=\(isCurrentBufferAlternate)")
            }
            buffer.lines [buffer.y + buffer.yBase] = buffer.getBlankLine (attribute: eraseAttr ())
            updateRange (startLine: buffer.scrollTop, endLine: buffer.scrollBottom)
        } else if buffer.y > 0 {
            buffer.y -= 1
        }
    }
    
    /**
     * Provides a baseline set of environment variables that would be useful to run the terminal,
     * you can customzie these accordingly.
     * - Parameters:
     *  - termName: desired name for the terminal, if set to nil (the default), it sets it to xterm-256color
     *  - trueColor: if set to true, sets the COLORTERM variable to truecolor,
     * - Returns: an array of default environment variables that include TERM set to the specified value, or xterm-256color,
     * and if trueColor is true, COLORTERM=truecolor, the LANG=en_US.UTF-8 and it mirrors the currently set values
     * for LOGNAME, USER, DISPLAY, LC_TYPE, USER and HOME.
     */
    public static func getEnvironmentVariables (termName: String? = nil, trueColor: Bool = true) -> [String]
    {
        var l : [String] = []
        let t = termName == nil ? "xterm-256color" : termName!
        l.append ("TERM=\(t)")
        if trueColor {
            l.append ("COLORTERM=truecolor")
        }
        
        // Without this, tools like "vi" produce sequences that are not UTF-8 friendly
        l.append ("LANG=en_US.UTF-8")
        let env = ProcessInfo.processInfo.environment
        for x in ["LOGNAME", "USER", "DISPLAY", "LC_TYPE", "USER", "HOME" /* "PATH" */ ] {
            if env.keys.contains(x) {
                l.append ("\(x)=\(env[x]!)")
            }
        }
        return l
    }
    
    /// Specified the kind of buffer is being requested from the terminal
    public enum BufferKind {
        /// The currently active buffer (can be either normal or alt)
        case active
        /// The normal buffer, regardless of which buffer is active
        case normal
        /// The alternate buffer, regardless of which buffer is active
        case alt
    }
    
    func bufferFromKind (kind: BufferKind) -> Buffer
    {
        switch kind {
        case .active:
            return buffer
        case .normal:
            return normalBuffer
        case .alt:
            return altBuffer
        }
    }
    
    /// Returns the contents of the specified terminal buffer encoded as UTF8 in the provided Data buffer
    /// - Parameter kind: which buffer to retrive the data for
    /// - Parameter encoding: which encoding to use for the returned value, defaults to utf8
    public func getBufferAsData (kind: BufferKind = .active, encoding: String.Encoding = .utf8) -> Data
    {
        var result = Data()
        
        let b = bufferFromKind(kind: kind)
        let newLine = Data([10])
        for row in 0..<b.lines.count {
            let bufferLine = b.lines [row]
            let str = bufferLine.translateToString(trimRight: true)
            if let encoded = str.data(using: encoding) {
                result.append (encoded)
                result.append (newLine)
            }
        }
        return result
    }
    
    /// Returns the text between the specified range
    ///
    public func getText (start: Position, end: Position) -> String
    {
        let lines = getSelectedLines(p1: start, p2: end)
        if lines.count == 0 {
            return ""
        }
        var r = ""
        for line in lines {
            r += line.toString()
        }
        return r
    }

    // This version validates the input parameters
    func getSelectedLines(p1: Position, p2: Position) -> [Line]
    {
        var start = p1
        var end = p2
        let b = buffer
        
        switch Position.compare (start, end) {
        case .equal:
            return []
        case .after:
            let tmp = start
            start = end
            end = tmp
        case .before:
            break
        }
        if start.row < 0 || start.row > b.lines.count {
            return []
        }
        
        if end.row >= b.lines.count {
            end.row = b.lines.count-1
        }
        return _getSelectedLines(start, end)
    }
    
    func _getSelectedLines(_ start: Position, _ end: Position) -> [Line]
    {
        var lines: [Line] = []
        let buf = buffer
        var str = ""
        var currentLine = Line ()
        lines.append(currentLine)
        
        // keep a list of blank lines that we see. if we see content after a group
        // of blanks, add those blanks but skip all remaining / trailing blanks
        // these will be blank lines in the selected text output
        var blanks: [LineFragment] = []
        
        func addBlanks () {
            var lastLine = -1;
            for b in blanks {
                if lastLine != -1 && b.line != lastLine {
                    currentLine = Line ()
                    lines.append(currentLine)
                }
                
                lastLine = b.line
                currentLine.add(fragment: b)
            }
            blanks = []
        };
        
        // get the first line
        var bufferLine = buf.lines [start.row]
        if bufferLine.hasAnyContent() {
            let str: String = translateBufferLineToString (buffer: buf, line: start.row, start: start.col, end: start.row < end.row ? -1 : end.col)
            
            let fragment = LineFragment (text: str, line: start.row, location: start.col, length: str.count)
            currentLine.add (fragment: fragment)
        }
        
        // get the middle rows
        var line = start.row + 1
        var isWrapped = false
        while line < end.row {
            bufferLine = buffer.lines [line]
            isWrapped = bufferLine.isWrapped
            
            str = translateBufferLineToString (buffer: buf, line: line, start: 0, end: -1)
            
            if bufferLine.hasAnyContent () {
                // add previously gathered blank fragments
                addBlanks ()
                
                if !isWrapped {
                    // this line is not a wrapped line, so the
                    // prior line has a hard linefeed
                    // add a fragment to that line
                    currentLine.add (fragment: LineFragment.newLine (line: line - 1))
                    
                    // start a new line
                    currentLine = Line ()
                    lines.append(currentLine)
                }
                
                // add the text we found to the current line
                currentLine.add (fragment: LineFragment (text: str, line: line, location: 0, length: str.count))
            } else {
                // this line has no content, which means that it's a blank line inserted
                // somehow, or one of the trailing blank lines after the last actual content
                // make a note of the line
                // check that this line is a wrapped line, if so, add a line feed fragment
                if !isWrapped {
                    blanks.append (LineFragment.newLine (line: line - 1))
                }
                
                blanks.append(LineFragment (text: str, line: line, location: 0, length: str.count))
            }
            
            line += 1
        }
        
        // get the last row
        if end.row != start.row {
            bufferLine = buffer.lines [end.row]
            if bufferLine.hasAnyContent () {
                addBlanks ()
                
                isWrapped = bufferLine.isWrapped
                str = translateBufferLineToString (buffer: buf, line: end.row, start: 0, end: end.col)
                if !isWrapped {
                    currentLine.add(fragment: LineFragment.newLine (line: line - 1))
                    currentLine = Line ()
                    lines.append(currentLine)
                }
                
                currentLine.add (fragment: LineFragment (text: str, line: line, location: 0, length: str.count))
            }
        }
        return lines
    }
    
    func translateBufferLineToString (buffer: Buffer, line: Int, start: Int, end: Int) -> String
    {
        buffer.translateBufferLineToString(lineIndex: line, trimRight: true, startCol: start, endCol: end).replacingOccurrences(of: "\u{0}", with: " ")
    }
}

// Default implementations
public extension TerminalDelegate {
    func cursorStyleChanged (source: Terminal, newStyle: CursorStyle)
    {
        // Do nothing
    }
    
    func setTerminalTitle (source: Terminal, title: String) {
        // Do nothing
    }

    func setTerminalIconTitle (source: Terminal, title: String) {
        // nothing
    }
    
    func scrolled(source: Terminal, yDisp: Int) {
        // nothing
    }
    
    func linefeed(source: Terminal) {
        // nothing
    }
    
    func bufferActivated(source: Terminal) {
        // nothing
    }
    
    func windowCommand(source: Terminal, command: Terminal.WindowManipulationCommand) -> [UInt8]? {
        // no special handling
        return nil
    }
    
    func sizeChanged(source: Terminal) {
        // nothing
    }
    
    func bell (source: Terminal){
        // nothing
    }
    
    func isProcessTrusted (source: Terminal) -> Bool {
        return true
    }
    
    func selectionChanged (source: Terminal){
        // nothing
    }
    
    func showCursor(source: Terminal) {
        // nothing
    }

    func hideCursor(source: Terminal) {
        // nothing
    }

    func mouseModeChanged(source: Terminal) {
    }
    
    func hostCurrentDirectoryUpdated (source: Terminal) {
    }
    
    func hostCurrentDocumentUpdated (source: Terminal) {
    }
    
    func colorChanged (source: Terminal, idx: Int?) {
        
    }
    
    func getColors (source: Terminal) -> (foreground: Color, background: Color)
    {
        return (source.foregroundColor, source.backgroundColor)
    }
    
    func setForegroundColor (source: Terminal, color: Color)
    {
        source.foregroundColor = color
    }
    
    func setBackgroundColor (source: Terminal, color: Color)
    {
        source.backgroundColor = color
    }
    
    func setCursorColor (source: Terminal, color: Color?)
    {
        source.cursorColor = color
    }
    
    func iTermContent (source: Terminal, content: ArraySlice<UInt8>) {
    }
    
    func clipboardCopy(source: Terminal, content: Data) {
    }
    
    func notify(source: Terminal, title: String, body: String) {
    }
    
    func createImageFromBitmap (source: Terminal, bytes: inout [UInt8], width: Int, height: Int){
    }

    func createImage (source: Terminal, data: Data, width: ImageSizeRequest, height: ImageSizeRequest, preserveAspectRatio: Bool) {
    }    
}
