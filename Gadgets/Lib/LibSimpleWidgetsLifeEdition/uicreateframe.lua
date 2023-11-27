local frameConstructors = {
  SimpleLifeCheckbox    = Library.LibSimpleWidgetsLifeEdition.Checkbox, --SimpleLife
  SimpleLifeGrid        = Library.LibSimpleWidgetsLifeEdition.Grid,
  SimpleLifeList        = Library.LibSimpleWidgetsLifeEdition.List,
  SimpleLifeRadioButton = Library.LibSimpleWidgetsLifeEdition.RadioButton,
  SimpleLifeScrollList  = Library.LibSimpleWidgetsLifeEdition.ScrollList,
  SimpleLifeScrollView  = Library.LibSimpleWidgetsLifeEdition.ScrollView,
  SimpleLifeSelect      = Library.LibSimpleWidgetsLifeEdition.Select,
  SimpleLifeSlider      = Library.LibSimpleWidgetsLifeEdition.Slider,
  SimpleLifeTabView     = Library.LibSimpleWidgetsLifeEdition.TabView,
  SimpleLifeTextArea    = Library.LibSimpleWidgetsLifeEdition.TextArea,
  SimpleLifeTooltip     = Library.LibSimpleWidgetsLifeEdition.Tooltip,
  SimpleLifeWindow      = Library.LibSimpleWidgetsLifeEdition.Window,
  SimpleLifeLifeWindow  = Library.LibSimpleWidgetsLifeEdition.LifeWindow,
}

local oldUICreateFrame = UI.CreateFrame
UI.CreateFrame = function(frameType, name, parent)
  assert(type(frameType) == "string", "param 1 must be a string!")
  assert(type(name) == "string", "param 2 must be a string!")
  assert(type(parent) == "table", "param 3 must be a valid frame parent!")

  local constructor = frameConstructors[frameType]
  if constructor then
    return constructor(name, parent)
  else
    return oldUICreateFrame(frameType, name, parent)
  end
end
