//
//  CBPinEntryView.swift
//  Pods
//
//  Created by Chris Byatt on 18/03/2017.
//
//

import UIKit

public protocol CBPinEntryViewDelegate: class {
    func entryChanged(_ completed: Bool)
    func entryCompleted(with entry: String?)
}

@IBDesignable open class CBPinEntryView: UIView {

    @IBInspectable open var length: Int = CBPinEntryViewDefaults.length {
        didSet {
            commonInit()
        }
    }
    
    @IBInspectable open var itemWidth: CGFloat = CBPinEntryViewDefaults.itemWidth {
        didSet {
            commonInit()
        }
    }

    @IBInspectable open var itemHeight: CGFloat = CBPinEntryViewDefaults.itemHeight {
        didSet {
            commonInit()
        }
    }
    
    @IBInspectable open var spacing: CGFloat = CBPinEntryViewDefaults.spacing {
        didSet {
            commonInit()
        }
    }

    @IBInspectable open var entryCornerRadius: CGFloat = CBPinEntryViewDefaults.entryCornerRadius {
        didSet {
            if (oldValue != entryCornerRadius) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryBorderWidth: CGFloat = CBPinEntryViewDefaults.entryBorderWidth {
        didSet {
            if (oldValue != entryBorderWidth) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryDefaultBorderColour: UIColor = CBPinEntryViewDefaults.entryDefaultBorderColour {
        didSet {
            if (oldValue != entryDefaultBorderColour) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryBorderColour: UIColor = CBPinEntryViewDefaults.entryBorderColour {
        didSet {
            if (oldValue != entryBorderColour) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryEditingBackgroundColour: UIColor = CBPinEntryViewDefaults.entryEditingBackgroundColour {
        didSet {
            if (oldValue != entryEditingBackgroundColour) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryErrorBorderColour: UIColor = CBPinEntryViewDefaults.entryErrorColour

    @IBInspectable open var entryBackgroundColour: UIColor = CBPinEntryViewDefaults.entryBackgroundColour {
        didSet {
            if (oldValue != entryBackgroundColour) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryTextColour: UIColor = CBPinEntryViewDefaults.entryTextColour {
        didSet {
            if (oldValue != entryTextColour) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var entryFont: UIFont = CBPinEntryViewDefaults.entryFont {
        didSet {
            if (oldValue != entryFont) {
                updateButtonStyles()
            }
        }
    }

    @IBInspectable open var isCursorVisible: Bool = CBPinEntryViewDefaults.isCursorVisible {
        didSet {
            setTextFieldPosition()
        }
    }

    @IBInspectable open var isSecure: Bool = CBPinEntryViewDefaults.isSecure

    @IBInspectable open var secureCharacter: String = CBPinEntryViewDefaults.secureCharacter
    
    @IBInspectable open var keyboardType: Int = CBPinEntryViewDefaults.keyboardType {
        didSet {
            if (oldValue != keyboardType) {
                updateTextFieldStyles()
            }
        }
    }
    
    open var textContentType: UITextContentType? = nil {
        didSet {
            if #available(iOS 10, *) {
                if (oldValue != textContentType) {
                    textField.textContentType = textContentType
                }
            }
        }
    }

    @IBInspectable open var autocapitalizationType: Int = CBPinEntryViewDefaults.autocapitalizationType {
        didSet {
            if (oldValue != autocapitalizationType) {
                updateTextFieldStyles()
            }
        }
    }
    
    private var associatedTopInset: CGFloat = 0.0
    @IBInspectable var topInset: CGFloat {
        get {
            return associatedTopInset
        }
        
        set {
            associatedTopInset = newValue
            commonInit()
        }
    }
    
    private var associatedLeftInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat {
        get {
            return associatedLeftInset
        }
        
        set {
            associatedLeftInset = newValue
            commonInit()
        }
    }
    
    private var associatedBottomInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat {
        get {
            return associatedBottomInset
        }
        
        set {
            associatedBottomInset = newValue
            commonInit()
        }
    }
    
    private var associatedRightInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat {
        get {
            return associatedRightInset
        }
        
        set {
            associatedRightInset = newValue
            commonInit()
        }
    }
    
    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets.init(top: associatedTopInset, left: associatedLeftInset, bottom: associatedBottomInset, right: associatedRightInset)
        }
        
        set {
            associatedTopInset = newValue.top
            associatedLeftInset = newValue.left
            associatedBottomInset = newValue.bottom
            associatedRightInset = newValue.right
            commonInit()
        }
    }
    
    @IBInspectable var textFieldHeightMultiplier: CGFloat = 0.8
    
    @IBInspectable var cursorTopInsetInTextField: CGFloat = 1.0

    public enum AllowedEntryTypes: String {
        case any, numerical, alphanumeric, letters
    }

    open var allowedEntryTypes: AllowedEntryTypes = .numerical


    @IBInspectable open var isUnderlined: Bool = false {
        didSet {
            commonInit()
        }
    }

    private var stackView: UIStackView?
    private var textField: UITextField!

    open var errorMode: Bool = false

    fileprivate var entryButtons: [UIButton] = [UIButton]()
        
    private var isPastable = false

    public weak var delegate: CBPinEntryViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        makePastable()
        
        commonInit()
    }

    override open func prepareForInterfaceBuilder() {
        commonInit()
    }
    
    @discardableResult open override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        
        if let firstButton = entryButtons.first {
            didPressCodeButton(firstButton)
        }
        
        textField.becomeFirstResponder()
        
        return true
    }
    
    @discardableResult open override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        
        setError(isError: false)
        
        return textField.resignFirstResponder()
    }

    public func makePastable() {
        if (isPastable) { return }
        
        isUserInteractionEnabled = true
        
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.pasteMenu))
        longGestureRecognizer.minimumPressDuration = 0.2

        addGestureRecognizer(longGestureRecognizer)
        
        isPastable = true
    }

    @objc func pasteMenu(sender: Any?) {
        var targetRect = CGRect(
            origin: CGPoint.init(
                x: bounds.origin.x,
                y: bounds.origin.y
            ),
            size: CGSize.init(
                width: bounds.size.width,
                height: bounds.size.height
            )
        )
        
        targetRect.origin.y += associatedTopInset + cursorTopInsetInTextField
        
        targetRect.origin.y += (itemHeight - (textFieldHeightMultiplier * itemHeight)) / 2
        
        targetRect.origin.x = associatedLeftInset + textField.bounds.width / 2
        
        let textCount = (textField?.text ?? "").count
        if (textCount < length) {
            targetRect.size.width = itemWidth
            var insetLeft: CGFloat = 0
            
            let additionalCount = textCount
            
            if (additionalCount > 0) {
                let additionalCountCGFloat = CGFloat(additionalCount)
                insetLeft += itemWidth * additionalCountCGFloat - 1
                insetLeft += spacing * additionalCountCGFloat
            }
            
            targetRect.origin.x += insetLeft
        }
        
        UIMenuController.shared.setTargetRect(targetRect, in: self)

        UIMenuController.shared.setMenuVisible(true, animated: true)
    }

    open override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        return true
    }

    override public func paste(_ sender: Any?) {
        guard let textField = self.textField else {
            return
        }
        
        if let string = UIPasteboard.general.string, !string.isEmpty {
            let _ = self.textField(textField, shouldChangeCharactersIn: NSRange.init(location: 0, length: string.count), replacementString: string)
        }

        UIMenuController.shared.setMenuVisible(false, animated: true)
        
        textField.becomeFirstResponder()
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(paste(_:)))
    }


    private func commonInit() {
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        stackView = nil
        textField = nil
        entryButtons.removeAll()
        
        setupView()
        setupStackView()
        setupTextField()

        createButtons()
    }
    
    private func setupView() {
        ForConstraint: for constraint in self.constraints {
            if (constraint.firstAttribute == .width ||
                constraint.secondAttribute == .width) {
                constraint.isActive = false
                self.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        ForConstraint: for constraint in self.constraints {
            if (constraint.firstAttribute == .height ||
                constraint.secondAttribute == .height) {
                constraint.isActive = false
                self.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        let itemsHeight: CGFloat = associatedTopInset + associatedBottomInset + itemHeight
        
        self.heightAnchor.constraint(equalToConstant: itemsHeight).isActive = true
        
        var itemsWidth: CGFloat = associatedLeftInset + associatedRightInset
        
        if (length > 0) {
            let lengthCGFloat = CGFloat(length)
            
            itemsWidth += itemWidth * lengthCGFloat
            itemsWidth += spacing * (lengthCGFloat - 1)
        }
        
        self.widthAnchor.constraint(equalToConstant: itemsWidth).isActive = true
    }

    private func setupStackView() {
        let stackView = UIStackView(frame: bounds)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: associatedLeftInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -associatedRightInset).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: associatedTopInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -associatedBottomInset).isActive = true
        
        self.stackView = stackView
    }

    private func setupTextField() {
        let textField = CBPinEntryViewTextField(frame: bounds)
        textField.responderStandardEditActions = self
        textField.delegate = self
        textField.addTarget(self, action: #selector(textfieldChanged(_:)), for: .editingChanged)
        
        self.addSubview(textField)

        textField.isHidden = true
        
        self.textField = textField
        
        updateTextFieldStyles()
        
        setTextFieldPosition()
    }
    
    func updateTextFieldStyles() {
        guard let textField = self.textField else { return }
        
        textField.autocorrectionType = .no
        textField.keyboardType = UIKeyboardType(rawValue: keyboardType) ?? UIKeyboardType(rawValue: CBPinEntryViewDefaults.keyboardType)!
        textField.autocapitalizationType = UITextAutocapitalizationType.init(rawValue: autocapitalizationType) ?? UITextAutocapitalizationType.init(rawValue: CBPinEntryViewDefaults.autocapitalizationType)!
        if #available(iOS 10.0, *) {
            textField.textContentType = textContentType
        }
    }
    
    private func setTextFieldPosition() {
        guard let textField = self.textField else { return }
        
        textField.textColor = .clear
        
        ForConstraint: for constraint in textField.constraints {
            if (constraint.firstAttribute == .width ||
                constraint.secondAttribute == .width) {
                constraint.isActive = false
                textField.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        ForConstraint: for constraint in self.constraints {
            if ((constraint.firstAttribute == .top && (constraint.firstItem as? UIView) == textField) ||
                (constraint.secondAttribute == .top && (constraint.secondItem as? UIView) == textField)) {
                constraint.isActive = false
                self.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        ForConstraint: for constraint in textField.constraints {
            if (constraint.firstAttribute == .height ||
                constraint.secondAttribute == .height) {
                constraint.isActive = false
                self.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        textField.translatesAutoresizingMaskIntoConstraints = !isCursorVisible
        
        if (!isCursorVisible) {
            textField.isHidden = true
            
            return
        }
        
        if (textField.superview == nil) { return }
        
        let height = itemHeight * textFieldHeightMultiplier
        
        let topInset = associatedTopInset + cursorTopInsetInTextField + ((itemHeight - height) / 2)
        
        textField.widthAnchor.constraint(equalToConstant: 2).isActive = true
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: topInset).isActive = true
        textField.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    private func resetTextFieldPosition(button: UIButton, stringLength: Int) {
        guard let textField = self.textField else { return }
        
        ForConstraint: for constraint in self.constraints {
            if ((constraint.firstAttribute == .leading && (constraint.firstItem as? UIView) == textField) ||
                (constraint.secondAttribute == .leading && (constraint.secondItem as? UIView) == textField)) {
                constraint.isActive = false
                self.removeConstraint(constraint)
                break ForConstraint
            }
        }
        
        textField.translatesAutoresizingMaskIntoConstraints = !isCursorVisible
        
        if (!isCursorVisible) {
            textField.isHidden = true
            
            return
        }
        
        if (textField.superview == nil) { return }
        
        ForI: for i in 0 ..< entryButtons.count {
            if (entryButtons[i] == button) {
                let positionCGFloat = CGFloat(i)
                
                let lengthCGFloat = CGFloat(length)

                let buttonBoundsWidth = button.bounds.width
                
                var constantLeading: CGFloat = associatedLeftInset + (buttonBoundsWidth / 2) - (textField.bounds.width / lengthCGFloat)
                
                if (i > 0) {
                    constantLeading += (buttonBoundsWidth + spacing) * positionCGFloat
                }
                
                textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constantLeading).isActive = true
                
                textField.isHidden = false
                
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
                break ForI
            }
        }
    }

    private func createButtons() {
        for i in 0..<length {
            let button = UIButton()
            button.backgroundColor = entryBackgroundColour
            button.setTitleColor(entryTextColour, for: .normal)
            button.titleLabel?.font = entryFont
            button.layer.cornerRadius = entryCornerRadius

            if (isUnderlined) {
                button.addBottomBorder(thickness: entryBorderWidth, color: entryDefaultBorderColour)
            } else {
                button.layer.borderColor = entryDefaultBorderColour.cgColor
                button.layer.borderWidth = entryBorderWidth
            }

            button.tag = i + 1

            button.addTarget(self, action: #selector(didPressCodeButton(_:)), for: .touchUpInside)
            
            entryButtons.append(button)
            
            stackView?.addArrangedSubview(button)
        }
    }

    private func updateButtonStyles() {
        for button in entryButtons {
            button.backgroundColor = entryBackgroundColour
            button.setTitleColor(entryTextColour, for: .normal)
            button.titleLabel?.font = entryFont

            button.layer.cornerRadius = entryCornerRadius
            button.layer.borderColor = entryDefaultBorderColour.cgColor
            button.layer.borderWidth = entryBorderWidth
        }
    }

    @objc private func didPressCodeButton(_ sender: UIButton) {
        textField.becomeFirstResponder()
        
        errorMode = false
        
        let entryIndex = textField.text!.count + 1
        for button in entryButtons {
            button.layer.borderColor = entryBorderColour.cgColor
            
            if (button.tag == entryIndex) {
                button.layer.borderColor = entryBorderColour.cgColor
                button.backgroundColor = entryEditingBackgroundColour
                
                resetTextFieldPosition(button: button, stringLength: textField.text?.count ?? 0)
            } else {
                button.layer.borderColor = entryDefaultBorderColour.cgColor
                button.backgroundColor = entryBackgroundColour
            }
        }
        
        textField.becomeFirstResponder()
    }
    
    open func setError(isError: Bool) {
        if (isError) {
            errorMode = true
            for button in entryButtons {
                if (isUnderlined) {
                    button.viewWithTag(9999)?.backgroundColor = entryErrorBorderColour
                } else {
                    button.layer.borderColor = entryErrorBorderColour.cgColor
                    button.layer.borderWidth = entryBorderWidth
                }
            }
        } else {
            errorMode = false
            for button in entryButtons {
                if (isUnderlined) {
                    button.viewWithTag(9999)?.backgroundColor = entryDefaultBorderColour
                } else {
                    button.layer.borderColor = entryDefaultBorderColour.cgColor
                    button.backgroundColor = entryBackgroundColour
                }
            }
        }
    }

    open func clearEntry() {
        setError(isError: false)
        textField.text = ""
        for button in entryButtons {
            button.setTitle("", for: .normal)
        }

        if let firstButton = entryButtons.first {
            didPressCodeButton(firstButton)
        }
    }

    open func getPinAsInt() -> Int? {
        if let intOutput = Int(textField.text!) {
            return intOutput
        }

        return nil
    }

    open func getPinAsString() -> String {
        return textField.text!
    }
}

extension CBPinEntryView: UITextFieldDelegate {
    @objc func textfieldChanged(_ textField: UITextField) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
        
        let isCompleted: Bool = textField.text!.count == length
        delegate?.entryChanged(isCompleted)
        
        if (isCompleted) {
            textField.isHidden = true
            
            for button in entryButtons {
                button.layer.borderColor = entryBorderColour.cgColor
                button.backgroundColor = entryBackgroundColour
            }
            
            delegate?.entryCompleted(with: textField.text)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorMode = false
        for button in entryButtons {
            button.layer.borderColor = entryBorderColour.cgColor
            button.backgroundColor = entryBackgroundColour
        }

        let isDeleting = (range.location == textField.text!.count - 1 && range.length == 1 && string == "")
        
        if (string.count > 0) {
            var isAllowed = true
            switch allowedEntryTypes {
            case .numerical: isAllowed = Scanner(string: string).scanInt(nil)
            case .letters: isAllowed = Scanner(string: string).scanCharacters(from: CharacterSet.letters, into: nil)
            case .alphanumeric: isAllowed = Scanner(string: string).scanCharacters(from: CharacterSet.alphanumerics, into: nil)
            case .any: break
            }

            if (!isAllowed) {
                if ((textField.text ?? "").isEmpty) {
                    textField.isHidden = true
                }
                
                becomeFirstResponder()
                
                return false
            }
        }

        let oldLength = textField.text!.count
        let replacementLength = string.count

        let newLength = oldLength + replacementLength
        
        if (isDeleting) {
            for button in entryButtons {
                if (button.tag == oldLength) {
                    button.layer.borderColor = entryBorderColour.cgColor
                    button.backgroundColor = entryEditingBackgroundColour
                    UIView.setAnimationsEnabled(false)
                    button.setTitle("", for: .normal)
                    UIView.setAnimationsEnabled(true)
                    
                    resetTextFieldPosition(button: button, stringLength: newLength)
                } else {
                    button.layer.borderColor = entryDefaultBorderColour.cgColor
                    button.backgroundColor = entryBackgroundColour
                }
            }
            
            return true
        }
        
        if (entryButtons.count < length) {
            becomeFirstResponder()
            
            return false
        }
        
        if (newLength > length) {
            becomeFirstResponder()
            
            return false
        }
        
        textField.text = (textField.text ?? "") + string
        
        let newText = Array(textField.text!)
        
        for i in 0 ..< newLength + 1 {
            if (i == entryButtons.count) {
                resetTextFieldPosition(button: entryButtons[entryButtons.count - 1], stringLength: newLength)
                
                textField.isHidden = true
                
                break
            }
            
            let button = entryButtons[i]
            
            if (button.tag == newLength + 1) {
                button.layer.borderColor = entryBorderColour.cgColor
                button.backgroundColor = entryEditingBackgroundColour
                
                resetTextFieldPosition(button: button, stringLength: newLength)
            } else {
                if (!isSecure) {
                    button.setTitle(String(newText[i]), for: .normal)
                } else {
                    button.setTitle(secureCharacter, for: .normal)
                }
                
                button.layer.borderColor = entryDefaultBorderColour.cgColor
                button.backgroundColor = entryBackgroundColour
            }
        }
        
        textField.sendActions(for: .editingChanged)
        
        return false
    }
}

extension UIButton {
    func addBottomBorder(thickness: CGFloat, color: UIColor, cornerRadius: CGFloat = 8) {
        guard viewWithTag(9999) == nil else {
            return
        }

        let line = UIView()
        line.tag = 9999
        line.backgroundColor = color
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)

        line.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        line.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class CBPinEntryViewTextField: UITextField {
    weak var responderStandardEditActions: UIResponderStandardEditActions? = nil
    
    open override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        return responderStandardEditActions != nil
    }
    
    override func paste(_ sender: Any?) {
        responderStandardEditActions?.paste?(sender)
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return responderStandardEditActions != nil && (action == #selector(paste(_:)))
    }
}
