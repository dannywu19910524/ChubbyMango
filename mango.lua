Mango = {balance = 0}
--new可以视为构造函数
function Mango:new(o)
    o = o or {} --如果参数中没有提供table，则创建一个空的。
    --将新对象实例的metatable指向Mango表(类)，这样就可以将其视为模板了。
    setmetatable(o,self)
    --在将Mango的__index字段指向自己，以便新对象在访问Mango的函数和字段时，可被直接重定向。
    self.__index = self
    --最后返回构造后的对象实例
    return o
end


function Mango:deposit(v)
    --这里的self表示对象实例本身
    self.balance = self.balance + v
end

a = Mango:new()
a:deposit(100.0)
print(a.balance);