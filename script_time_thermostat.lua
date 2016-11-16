---

local debug = false

local hysteresis = 0.2
local activeswitch = 'Termostat aktiv'
local thermostat = 'Termostat stue'
local thermometer = 'Temperatur Stue'
local heaters = {'Ovn kjokken', 'Ovn stue'}

local temperature = otherdevices[thermometer]
local target = otherdevices[thermostat]

---

commandArray = {}

function timedifference(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

function debugPrint(what)
   if (debug) then print(what) end
end

function turnHeaters(state)
   local cmd = {}
   for i,heater in pairs(heaters) do
      if otherdevices[heater] ~= state then
         delayedstate = string.format("%s AFTER %d", state, i)
         cmd[heater] = delayedstate
      end
   end
   return cmd
end

-- Only run if thermostat is active
if (otherdevices[activeswitch] == "Off") then
   return {}
end

-- Turn off heating if thermometer data is too old.
if (timedifference(otherdevices_lastupdate[thermometer]) > 60 * 30) then
   print("Sensor data is too old!")
   commandArray = turnHeaters("Off")
   return commandArray
end

debugPrint(string.format("Temperature: %.1f", temperature))
debugPrint(string.format("Target: %.1f", target))

if (target - temperature > hysteresis) then
   debugPrint("Heat on!")
   commandArray = turnHeaters("On")
else
   debugPrint("Heat off!")
   commandArray = turnHeaters("Off")
end

return commandArray
