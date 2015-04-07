AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new()
    local self = {}

    self.states = {}
    self.activeState = nil
    self.defaultState = nil

    self.playing = false

    self.anyStateRules = {}
    self.params = {}

    setmetatable(self, AnimationController)
    return self 
end

function AnimationController:resetParams()
    self.params = {}
end

function AnimationController:setParam(name, val)
    print("AnimationController:setParam - setting ", name, " to ", tostring(val))
    self.params[name] = val
end

function AnimationController:incParam(name, amount)
    if self.params[name] then
        assert(type(self.params[name]) == "number")
    else
        self.params[name] = 0
    end

    self.params[name] = self.params[name] + (amount or 1)
end

function AnimationController:decParam(name, amount)
    self:incParam(-1 * amount)
end

function AnimationController:toggleParam(name)
    if self.params[name] then
        assert(type(self.params[name]) == "boolean")
    else
        self.params[name] = false
    end

    self.params[name] = not self.params[name]
end

function AnimationController:addState(state)
    self.states[state.name] = state
end

function AnimationController:addAnyStateRule(rule)
    table.insert(self.anyStateRules, rule)
end

function AnimationController:update(dt)
    local isRuleSatisfied, destinationName = self.activeState:checkRules(self.params) 
    if isRuleSatisfied then
        self.changeState(destinationName)
    else
        for rule in ipairs(self.anyStateRules) do
            isRuleSatisfied, destinationName = rule:satisfied(self.params)
            if isRuleSatisfied then
                self.changeState(destinationName)
            end
        end
    end

    if self.playing then
        self.activeState:update(dt)
    end
end

function AnimationController:changeState(destinationStateName)
    print("AnimationController - changing state to: ", destinationStateName)
    self.activeState = self.states[destinationStateName]
end

function AnimationController:draw(x,y)
    self.activeState:draw(x,y)
end

function AnimationController:play()
    self.playing = true
    self.activeState:play()
end

function AnimationController:pause()
    self.playing = false
    self.activeState:pause()
end

AnimationState = {}
AnimationState.__index = AnimationState

function AnimationState.new(animation)
    local self = {}

    self.animation = animation
    self.rules = {}

    setmetatable(self, AnimationState)
    return self
end

function AnimationState:update(dt)
    self.animation:update(dt)
end

function AnimationState:draw(x,y)
    self.animation:draw(x,y)
end

function AnimationState:checkRules(params)
    for rule in ipairs(self.rules) do
        if rule:satisfied(params) then
            return true, rule.destination
        end
    end
    return false
end

function AnimationState:addRule(rule)
    table.insert(self.rules, rule)
end

function AnimationState:play()
    self.animation:play()
end

function AnimationState:pause()
    self.animation:pause()
end

StateRule = {}
StateRule.__index = StateRule

function StateRule.new(destinationName)
    self = {}
    self.destination = destinationName
    self.conditions = {}
    setmetatable(self, StateRule)
    return self
end

function StateRule:addConditionEqualTo(name, val)
    local condition = function(params)
        return params[name] == val
    end

    table.insert(self.conditions, condition)
end

function StateRule:addConditionGreaterThan(name, val)
    local condition = function(params)
        return params[name] and params[name] > val
    end

    table.insert(self.conditions, condition)
end

function StateRule:addConditionLessThan(name, val)
    local condition = function(params)
        return params[name] and params[name] < val
    end

    table.insert(self.conditions, condition)
end

function StateRule:satisfied(params)
    for conditionFunc in ipairs(self.conditions) do
        if not conditionFunc(params) then 
            return false
        end
    end

    return true
end
