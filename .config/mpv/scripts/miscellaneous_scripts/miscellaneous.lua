-- Add this to import:
--local script_dir =  mp.get_script_directory() 
--local misc_lua = script_dir .. '/../miscellaneous_scripts/miscellaneous.lua'
--package.path = script_dir .. "/?.lua;" .. misc_lua .. ";" .. package.path
--local misc = require 'miscellaneous.lua'
-- eða með 
--local script_dir =  mp.command_native( {"expand-path", "~~exe_dir/scripts" } )
--local misc_lua = script_dir .. '/miscellaneous_scripts/miscellaneous.lua'
--package.path = misc_lua .. ";" .. package.path

local utils = require 'mp.utils'
local sha256

local misc_dir =  mp.command_native({"expand-path", "~~exe_dir/scripts/miscellaneous_scripts/"})
package.path = misc_dir .. ";" .. package.path 

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end



--[[
minified code below is a combination of:
-sha256 implementation from
http://lua-users.org/wiki/SecureHashAlgorithm
-lua implementation of bit32 (used as fallback on lua5.1) from
https://www.snpedia.com/extensions/Scribunto/engines/LuaCommon/lualib/bit32.lua
both are licensed under the MIT below:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
do local b,c,d,e,f;if bit32 then b,c,d,e,f=bit32.band,bit32.rrotate,bit32.bxor,bit32.rshift,bit32.bnot else f=function(g)g=math.floor(tonumber(g))%0x100000000;return(-g-1)%0x100000000 end;local h={[0]={[0]=0,0,0,0},[1]={[0]=0,1,0,1},[2]={[0]=0,0,2,2},[3]={[0]=0,1,2,3}}local i={[0]={[0]=0,1,2,3},[1]={[0]=1,0,3,2},[2]={[0]=2,3,0,1},[3]={[0]=3,2,1,0}}local function j(k,l,m,n,o)for p=1,m do l[p]=math.floor(tonumber(l[p]))%0x100000000 end;local q=1;local r=0;for s=0,31,2 do local t=n;for p=1,m do t=o[t][l[p]%4]l[p]=math.floor(l[p]/4)end;r=r+t*q;q=q*4 end;return r end;b=function(...)return j('band',{...},select('#',...),3,h)end;d=function(...)return j('bxor',{...},select('#',...),0,i)end;e=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=math.floor(tonumber(u))u=math.min(math.max(-32,u),32)return math.floor(g/2^u)%0x100000000 end;c=function(g,u)g=math.floor(tonumber(g))%0x100000000;u=-math.floor(tonumber(u))%32;local g=g*2^u;return g%0x100000000+math.floor(g/0x100000000)end end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(n)return string.gsub(n,".",function(t)return string.format("%02x",string.byte(t))end)end;local function x(y,z)local n=""for p=1,z do local A=y%256;n=string.char(A)..n;y=(y-A)/256 end;return n end;local function B(n,p)local z=0;for p=p,p+3 do z=z*256+string.byte(n,p)end;return z end;local function C(D,E)local F=-(E+1+8)%64;E=x(8*E,8)D=D.."\128"..string.rep("\0",F)..E;return D end;local function G(H)H[1]=0x6a09e667;H[2]=0xbb67ae85;H[3]=0x3c6ef372;H[4]=0xa54ff53a;H[5]=0x510e527f;H[6]=0x9b05688c;H[7]=0x1f83d9ab;H[8]=0x5be0cd19;return H end;local function I(D,p,H)local J={}for K=1,16 do J[K]=B(D,p+(K-1)*4)end;for K=17,64 do local L=J[K-15]local M=d(c(L,7),c(L,18),e(L,3))L=J[K-2]local N=d(c(L,17),c(L,19),e(L,10))J[K]=J[K-16]+M+J[K-7]+N end;local O,s,t,P,Q,R,S,T=H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]for p=1,64 do local M=d(c(O,2),c(O,13),c(O,22))local U=d(b(O,s),b(O,t),b(s,t))local V=M+U;local N=d(c(Q,6),c(Q,11),c(Q,25))local W=d(b(Q,R),b(f(Q),S))local X=T+N+W+v[p]+J[p]T=S;S=R;R=Q;Q=P+X;P=t;t=s;s=O;O=X+V end;H[1]=b(H[1]+O)H[2]=b(H[2]+s)H[3]=b(H[3]+t)H[4]=b(H[4]+P)H[5]=b(H[5]+Q)H[6]=b(H[6]+R)H[7]=b(H[7]+S)H[8]=b(H[8]+T)end;local function Y(H)return w(x(H[1],4)..x(H[2],4)..x(H[3],4)..x(H[4],4)..x(H[5],4)..x(H[6],4)..x(H[7],4)..x(H[8],4))end;local Z={}sha256=function(D)D=C(D,#D)local H=G(Z)for p=1,#D,64 do I(D,p,H)end;return Y(H)end end
-- end of sha code

local months = { "janúar", "febrúar", "mars", "apríl", "maí", "júní", "júlí", "ágúst", "september", "október", "nóvember", "desember" }

local misc = {
    draw_ass = function(ass)
        local ww, wh = mp.get_osd_size()
        mp.set_osd_ass(ww, wh, ass)
    end,

    splitstring = function(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end,

    time_string_to_secs = function(self, tstring)
        if tstring:match(':') == nil then 
            return tstring
        end
        secminho = self.splitstring(tstring, ':')
        if #secminho == 3 then 
            h = secminho[1]
            m = secminho[2]
            s = secminho[3]
            if (s == nil) or (m == nil) or (h == nil) then return end
            total_secs = s + 60*m + 3600*h
        else
            m = secminho[1]
            s = secminho[2]
            if (s == nil) or (m == nil) then return end
            total_secs = s + 60*m
        end
        return total_secs
    end,

    disp_time = function(time)
        local hours = math.floor(time/3600)
        local minutes = math.floor((time % 3600)/60)
        local seconds = math.floor(time % 60)
        
        return string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end,

    timestamp_path = function(secs)
        local hours = math.floor(secs/3600)
        local minutes = math.floor((secs % 3600)/60)
        local seconds = math.floor(secs % 60)
        
        return string.format("%02d-%02d-%02d", hours, minutes, seconds)
    end,

    file_exists = function(file)
        local f = io.open(file, "rb")
        if f then f:close() end
        return f ~= nil
    end,

    insert_string = function(str1, str2, pos)
        return str1:sub(1,pos)..str2..str1:sub(pos+1)
    end,
    
    wrap = function(str, limit, indent, indent1, custom_newline)
        local newline = custom_newline or '\n'
        indent = indent or ""
        indent1 = indent1 or indent
        limit = limit or 79
        local here = 1-#indent1
        return indent1..str:gsub("(%s+)()(%S+)()",
            function(sp, st, word, fi)
                if fi-here > limit then
                here = st - #indent
                return newline..indent..word
            end
        end)
    end,
    
    comma_value = function(amount)
        if amount == nil then return end
        local formatted = amount
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end,

    format_datestring = function(date, extra, with_dashes)
        -- Formats datestring e.g. '20201222' -> 12. desember, 2020
        -- or if with_dashes == true: '2020-12-22' -> 12. desember, 2020
        if with_dashes == true then
            year    =       date:sub(1,4)
            month   =       date:sub(6,7)
            month_str =     months[tonumber(month)]
            day     =       date:sub(9,10)
        else 
            year    =       date:sub(1,4)
            month   =       date:sub(5,6)
            month_str =     months[tonumber(month)]
            day     =       date:sub(7,8)
        end
        -- TODO EF ENDAR A EINUM NOTA EINTOLU

        if extra == 'include_diff' then
            reference = os.time{day=day, year=year, month=month}
            daydiff = os.difftime(os.time(), reference) / (24 * 60 * 60)
            
            years = math.floor(daydiff / 365.24)
            wholedays = math.floor(math.fmod(daydiff, 365.24))
            eintala = math.fmod(wholedays, 10) == 1
            if eintala then 
                dagr = 'degi'
            else
                dagr = 'dögum'
            end
            if (years == 0) and (wholedays == 0) then 
                diff_str = ' (síðasta sólarhring)'
            elseif years == 0 then 
                diff_str = ' (fyrir ' .. wholedays .. ' ' .. dagr .. ')'
            elseif years == 1 then 
                diff_str = ' (fyrir ' .. years .. ' ári og ' .. wholedays .. ' ' .. dagr .. ')'
            else 
                diff_str = ' (fyrir ' .. years .. ' árum og ' .. wholedays .. ' ' .. dagr .. ')'
            end
            return day .. '. ' .. month_str .. ', ' .. year .. diff_str
        end 
            
        if date:len() == 12 then 
            hour =      date:sub(9,10)
            minutes =   date:sub(11,12)
            return day .. '. ' .. month_str .. ', ' .. year .. ' klukkan ' .. hour .. ':' .. minutes
        elseif date:len() == 14 then
            hour =      date:sub(9,10)
            minutes =   date:sub(11,12)
            seconds =   date:sub(13,14)
            return day .. '. ' .. month_str .. ', ' .. year .. ' klukkan ' .. hour .. ':' .. minutes .. ':' .. seconds
        end

        return day .. '. ' .. month_str .. ', ' .. year
    end,

    print_table = function(table)
        -- dont use this
        -- use dump (below) instead
        for k, v in pairs(table) do 
            print(k, v)
        end
    end,

    dump = function(self, o)
        -- prints table to console
        if type(o) == 'table' then
           local s = '{ '
           for k,v in pairs(o) do
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. self.dump(v) .. ','
           end
           return s .. '} '
        else
           return tostring(o)
        end
    end,
    

    dump_to_file = function(text)
        filepath_base = 'C:\\Users\\Kalmander\\Desktop\\mpv_dump_'
        file_nr = 1
        filepath = filepath_base .. tostring(file_nr) .. '.txt'
        function file_exists(name)
            local f=io.open(name,"r")
            if f~=nil then io.close(f) return true else return false end
        end
        already_exists = file_exists(filepath)
        while already_exists do 
            file_nr = file_nr + 1 
            filepath = filepath_base .. tostring(file_nr) .. '.txt'
            already_exists = file_exists(filepath)
        end

        file = io.open(filepath, 'w')
        if type(text) == 'string' then
            file:write(text)
        else
            for k, v in pairs(text) do 
                file:write(string.format("%02d", k), '  ', v, '\n')
            end
        end
        io.close(file)
    end,

    sha256 = function(string)
        return sha256(string)
    end,
    
    GetFileExtension = function(path)
        return path:match("^.+(%..+)$")
    end,

    RemoveFileExtension = function(path)
        -- The key in this pattern is the greediness of + and to use %. to represent the literal .
        return path:match("(.+)%..+")
    end,

    getTableSize = function(T)
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    end,
    
    printTableKeys = function(table)
        local msg = 'The table keys are: '
        for k, v in pairs(table) do 
            msg = msg .. k .. ', '
        end
        msg = msg:sub(1, #msg-2)
        print(msg)
    end,

    count_video_tracks = function()
        video_track_count = 0
        for i=0, mp.get_property('track-list/count')-1 do
            track_type = mp.get_property(string.format('track-list/%i/type', i))
            if track_type == 'video' then 
                video_track_count = video_track_count + 1
            end
        end
        return video_track_count
    end,

    parse_metadata_log_line = function(line)
        local line_duration = string.match(line, 'duration=(.*)  |  upload_date=')
        local line_date = string.match(line, '  |  upload_date=(.*)  |  thumbnail_path=')
        local line_path = string.match(line, '  |  thumbnail_path=(.*)  |')
        return {
            duration=line_duration,
            date=line_date,
            thumb_path=line_path
        }
    end,

    read_metadata_log = function(self, metadataLogPath)
        local metadata_table = {}
        local metlog = io.open(metadataLogPath, 'r')
        if metlog==nil then return {} end
        for line in metlog:lines() do 
            local line_md = self.parse_metadata_log_line(line)
            metadata_table[line_md['thumb_path']] = {
                duration=line_md['duration'],
                date=line_md['date']
            }
        end
        metlog.close()
        return metadata_table 
    end,

    normalize_path = function(path)
        if string.find(path, "://") then
            return path
        end
        path = utils.join_path(utils.getcwd(), path)
        if ON_WINDOWS then
            path = string.gsub(path, "\\", "/")
        end
        path = string.gsub(path, "/%./", "/")
        local n
        repeat
            path, n = string.gsub(path, "/[^/]*/%.%./", "/", 1)
        until n == 0
        return path
    end,

    sha256_normalized = function(self, string)
        return sha256(self.normalize_path(string))
    end,

}

return misc






