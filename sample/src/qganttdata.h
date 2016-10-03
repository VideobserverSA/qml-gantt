/****************************************************************************
**
** Copyright (C) 2015-2016 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of QML Gantt library.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

#ifndef QGANTTDATA_H
#define QGANTTDATA_H

#include <QObject>
#include <QColor>
#include <QVariant>

class QGanttData : public QObject{

    Q_OBJECT
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)
    Q_PROPERTY(QColor color  READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QVariant variant READ variant WRITE setVariant NOTIFY variantChanged)

public:
    explicit QGanttData(QObject *parent = 0);
    ~QGanttData();

    QString label() const;
    QColor  color() const;

    QVariant variant() const
    {
        return m_variant;
    }

signals:
    void labelChanged(QString arg);
    void colorChanged(QColor arg);

    void variantChanged(QVariant variant);

public slots:
    void setLabel(QString arg);
    void setColor(QColor arg);

    void setVariant(QVariant variant)
    {
        if (m_variant == variant)
            return;

        m_variant = variant;
        emit variantChanged(variant);
    }

private:
    QString m_label;
    QColor  m_color;
    QVariant m_variant;
};

inline QString QGanttData::label() const{
    return m_label;
}

inline QColor QGanttData::color() const{
    return m_color;
}

inline void QGanttData::setLabel(QString arg){
    if (m_label == arg)
        return;

    m_label = arg;
    emit labelChanged(arg);
}

inline void QGanttData::setColor(QColor arg){
    if (m_color == arg)
        return;

    m_color = arg;
    emit colorChanged(arg);
}

#endif // QGANTTDATA_H
