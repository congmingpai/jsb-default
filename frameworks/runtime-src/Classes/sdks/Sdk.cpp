#include "Sdk.h"
#include "SdkManager.h"
//#include "json/document.h"
//#include "json/rapidjson.h"
//#include "json/filestream.h"
//#include "json/prettywriter.h"
//#include "json/stringbuffer.h"

USING_NS_CC;

/********************
 * Sdk
 ********************/

Sdk::Sdk(const std::string &name)
: _name(name)
{
    SdkManager::addSdk(this);
}

Sdk::~Sdk()
{
    SdkManager::removeSdk(this);
}

/********************
 * Sdk Parameters
 ********************/

Sdk::Parameters::Parameters()
: _allocator(_json.GetAllocator())
{
    
}

Sdk::Parameters::Parameters(const std::string &params)
: _allocator(_json.GetAllocator())
{
    parse(params);
}

void Sdk::Parameters::parse(const std::string &params)
{
    _json.Parse(params.c_str());
    assert(!_json.HasParseError());
}

std::string Sdk::Parameters::stringify(bool pretty)
{
    if(pretty) {
        rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(_buffer);
        _json.Accept(writer);
        return _buffer.GetString();
    }
    else {
        rapidjson::Writer<rapidjson::StringBuffer> writer(_buffer);
        _json.Accept(writer);
        return _buffer.GetString();
    }
}

bool Sdk::Parameters::getBoolean(const std::string &key)
{
    assert(_json.HasMember(key.c_str()) && _json[key.c_str()].IsBool());
    return _json[key.c_str()].GetBool();
}

int Sdk::Parameters::getInt(const std::string &key)
{
    assert(_json.HasMember(key.c_str()) && _json[key.c_str()].IsInt());
    return _json[key.c_str()].GetInt();
}

double Sdk::Parameters::getDouble(const std::string &key)
{
    assert(_json.HasMember(key.c_str()) && _json[key.c_str()].IsDouble());
    return _json[key.c_str()].GetDouble();
}

std::string Sdk::Parameters::getString(const std::string &key)
{
    assert(_json.HasMember(key.c_str()) && _json[key.c_str()].IsString());
    return _json[key.c_str()].GetString();
}

void Sdk::Parameters::setBoolean(const std::string &key, bool value)
{
    _json.AddMember(rapidjson::Value(key.c_str(), _allocator), rapidjson::Value(value), _allocator);
}

void Sdk::Parameters::setInt(const std::string &key, int value)
{
    _json.AddMember(rapidjson::Value(key.c_str(), _allocator), rapidjson::Value(value), _allocator);
}

void Sdk::Parameters::setDouble(const std::string &key, double value)
{
    _json.AddMember(rapidjson::Value(key.c_str(), _allocator), rapidjson::Value(value), _allocator);
}

void Sdk::Parameters::setString(const std::string &key, const std::string &value)
{
    _json.AddMember(rapidjson::Value(key.c_str(), _allocator), rapidjson::Value(value.c_str(), _allocator), _allocator);
}
