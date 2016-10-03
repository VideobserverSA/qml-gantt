#ifndef MYTESTCLASS_H
#define MYTESTCLASS_H

#include <QObject>
#include <QString>

class MyTestClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString myString READ myString WRITE setMyString NOTIFY myStringChanged)
    QString m_myString;

public:
    explicit MyTestClass(QObject *parent = 0);

QString myString() const
{
    return m_myString;
}

signals:

void myStringChanged(QString myString);

public slots:
void setMyString(QString myString)
{
    if (m_myString == myString)
        return;

    m_myString = myString;
    emit myStringChanged(myString);
}
};

#endif // MYTESTCLASS_H
